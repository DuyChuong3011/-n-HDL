import sys
from PIL import Image
import os

# --- THAM SỐ CẤU HÌNH ---
TARGET_SIZE = (1024, 1024) 
# -------------------------

def convert_img_to_mem(input_path, output_path):
    if not os.path.exists(input_path):
        print(f"Lỗi: Không tìm thấy tệp đầu vào tại {input_path}")
        return

    try:
        with Image.open(input_path) as img:
            # ĐÃ SỬA: Chuyển đổi sang chế độ 'RGB' (24-bit)
            img = img.convert('RGB') 
            W_S, H_S = img.size 
            
            # ... (Logic Đổi kích thước và Độn viền giữ nguyên) ...
            ratio = min(TARGET_SIZE[0] / W_S, TARGET_SIZE[1] / H_S)
            new_W = int(W_S * ratio)
            new_H = int(H_S * ratio)
            
            img_resized = img.resize((new_W, new_H), Image.Resampling.LANCZOS)
            
            # Tạo khung hình mới với nền Đen RGB (0, 0, 0)
            new_img = Image.new('RGB', TARGET_SIZE, (0, 0, 0)) 
            x_offset = (TARGET_SIZE[0] - new_W) // 2
            y_offset = (TARGET_SIZE[1] - new_H) // 2
            new_img.paste(img_resized, (x_offset, y_offset))
            
            pixel_data_rgb = list(new_img.getdata())

    except Exception as e:
        print(f"Lỗi khi xử lý ảnh {input_path}: {e}")
        return

    # 5. Ghi dữ liệu pixel 24-bit ra tệp .mem
    with open(output_path, 'w') as f:
        print(f"Bắt đầu ghi {len(pixel_data_rgb)} pixel 24-bit ra {output_path}...")
        
        for r, g, b in pixel_data_rgb:
            # Ghép R, G, B thành giá trị 24-bit
            rgb_value = (r << 16) | (g << 8) | b
            # Ghi 6 ký tự hex (ví dụ: FFE0C0)
            f.write(f"{rgb_value:06x}\n")

    print(f"Đã chuyển đổi thành công. Tệp .mem đã được lưu tại: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Sử dụng: python img2mem.py <đường_dẫn_tới_ảnh_input.png/jpg> <tên_tệp_output.mem>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        convert_img_to_mem(input_file, output_file)