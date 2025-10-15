import sys
from PIL import Image
import os

# --- THAM SỐ CẤU HÌNH ---
TARGET_SIZE = (256, 256) 
# --- THAM SỐ CẤU HÌNH ---

def convert_png_to_mem(input_path, output_path):
    try:
        # Mở ảnh và chuyển đổi SANG GRAYSCALE (8-bit)
        with Image.open(input_path) as img:
            # Thay đổi kích thước và CHUYỂN ĐỔI sang chế độ 'L' (Luminance/Grayscale)
            # Chế độ 'L' là ảnh thang độ xám 8-bit.
            img = img.resize(TARGET_SIZE, Image.Resampling.LANCZOS).convert('L')
            
            # Dữ liệu pixel bây giờ chỉ là một giá trị 8-bit duy nhất cho mỗi pixel
            pixel_data = list(img.getdata())

    except FileNotFoundError:
        print(f"Lỗi: Không tìm thấy tệp {input_path}")
        return
    except Exception as e:
        print(f"Lỗi khi xử lý ảnh: {e}")
        return

    # Ghi dữ liệu pixel 8-bit ra tệp .mem
    with open(output_path, 'w') as f:
        print(f"Bắt đầu ghi {len(pixel_data)} pixel 8-bit ra {output_path}...")
        
        for value in pixel_data:
            # Ghi giá trị 8-bit (0x00 đến 0xFF) ra tệp ở định dạng thập lục phân (hex)
            # %02x đảm bảo giá trị luôn có 2 ký tự (ví dụ: 0F thay vì F)
            f.write(f"{value:02x}\n")

    print(f"Đã chuyển đổi thành công. Tệp .mem đã được lưu tại: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Sử dụng: python png2mem.py <đường_dẫn_tới_ảnh_input.png> <tên_tệp_output.mem>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        convert_png_to_mem(input_file, output_file)