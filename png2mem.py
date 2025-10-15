import sys
from PIL import Image
import os

# --- THAM SỐ CẤU HÌNH ---
TARGET_SIZE = (512, 512) 
# -------------------------

def convert_png_to_mem(input_path, output_path):
    try:
        with Image.open(input_path) as img:
            img = img.convert('L')
            W_S, H_S = img.size 
            
            # Tính toán tỷ lệ co giãn
            ratio = min(TARGET_SIZE[0] / W_S, TARGET_SIZE[1] / H_S)

            # Tính kích thước ảnh mới (đã co giãn tỷ lệ)
            new_W = int(W_S * ratio)
            new_H = int(H_S * ratio)
            
            # Đổi kích thước ảnh theo tỷ lệ (proportional resize)
            img_resized = img.resize((new_W, new_H), Image.Resampling.LANCZOS)
            
            # Tạo khung hình mới 720x720 với nền Đen (0 cho Grayscale)
            new_img = Image.new('L', TARGET_SIZE, 0) 
            
            # 💡 SỬA LỖI CĂN GIỮA 💡
            # Tính vị trí để dán ảnh vào chính giữa
            # Sử dụng phép chia làm tròn để tránh lỗi dịch chuyển 1 pixel
            x_offset = (TARGET_SIZE[0] - new_W) // 2
            y_offset = (TARGET_SIZE[1] - new_H) // 2
            
            # Dán ảnh đã đổi kích thước vào giữa khung hình
            new_img.paste(img_resized, (x_offset, y_offset))
            
            pixel_data = list(new_img.getdata())

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
            f.write(f"{value:02x}\n")

    print(f"Đã chuyển đổi thành công. Tệp .mem đã được lưu tại: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Sử dụng: python png2mem.py <đường_dẫn_tới_ảnh_input.png> <tên_tệp_output.mem>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        convert_png_to_mem(input_file, output_file)