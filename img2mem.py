import sys
from PIL import Image
import os

# --- THAM SỐ CẤU HÌNH ---
TARGET_SIZE = (512, 512) 
# -------------------------

# Đổi tên hàm để phản ánh chức năng chung hơn
def convert_img_to_mem(input_path, output_path):
    # Kiểm tra xem file có tồn tại không
    if not os.path.exists(input_path):
        print(f"Lỗi: Không tìm thấy tệp đầu vào tại {input_path}")
        return

    try:
        # Mở ảnh. Pillow tự động xử lý các định dạng PNG, JPG, BMP, v.v.
        with Image.open(input_path) as img:
            # 1. Chuyển đổi sang Grayscale (8-bit)
            img = img.convert('L') 
            W_S, H_S = img.size 
            
            # 2. Tính toán tỷ lệ co giãn (proportional resize)
            ratio = min(TARGET_SIZE[0] / W_S, TARGET_SIZE[1] / H_S)
            new_W = int(W_S * ratio)
            new_H = int(H_S * ratio)
            
            # 3. Đổi kích thước ảnh
            img_resized = img.resize((new_W, new_H), Image.Resampling.LANCZOS)
            
            # 4. Tạo khung hình mới 512x512 với nền Đen (padding)
            new_img = Image.new('L', TARGET_SIZE, 0) 
            x_offset = (TARGET_SIZE[0] - new_W) // 2
            y_offset = (TARGET_SIZE[1] - new_H) // 2
            new_img.paste(img_resized, (x_offset, y_offset))
            
            pixel_data = list(new_img.getdata())

    except Exception as e:
        print(f"Lỗi khi xử lý ảnh {input_path}: {e}")
        return

    # 5. Ghi dữ liệu pixel 8-bit ra tệp .mem
    with open(output_path, 'w') as f:
        print(f"Bắt đầu ghi {len(pixel_data)} pixel 8-bit ra {output_path}...")
        
        for value in pixel_data:
            # Ghi giá trị 8-bit (0x00 đến 0xFF)
            f.write(f"{value:02x}\n")

    print(f"Đã chuyển đổi thành công. Tệp .mem đã được lưu tại: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Sử dụng: python img2mem.py <đường_dẫn_tới_ảnh_input.png/jpg> <tên_tệp_output.mem>")
        print("Ví dụ: python img2mem.py my_image.jpg input_test.mem")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        convert_img_to_mem(input_file, output_file)