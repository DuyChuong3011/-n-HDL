import sys
from PIL import Image
import os

# --- THAM SỐ CẤU HÌNH ---
IMG_WIDTH = 1024
IMG_HEIGHT = 1024
PIXEL_COUNT = IMG_WIDTH * IMG_HEIGHT
# --- THAM SỐ CẤU HÌNH ---

def convert_mem_to_image(input_path, output_path):
    pixel_data_rgb = []
    
    try:
        with open(input_path, 'r') as f:
            lines = f.readlines()
            
            for line in lines:
                hex_value = line.strip()
                if not hex_value:
                    continue
                
                # --- LOGIC XỬ LÝ PIXEL (Đọc 24-bit) ---
                try:
                    rgb_int = int(hex_value, 16)
                    
                    # Tách 24-bit thành 3 kênh (R, G, B)
                    r = (rgb_int >> 16) & 0xFF
                    g = (rgb_int >> 8) & 0xFF
                    b = rgb_int & 0xFF
                    
                    pixel_data_rgb.append((r, g, b))
                
                except ValueError:
                    # Nếu gặp lỗi hex không hợp lệ, gán màu đen (0, 0, 0)
                    pixel_data_rgb.append((0, 0, 0))

    except FileNotFoundError:
        print(f"Lỗi: Không tìm thấy tệp .mem đầu vào tại {input_path}")
        return
    except Exception as e:
        print(f"Lỗi chung khi đọc/xử lý dữ liệu .mem: {e}")
        return

    # 2. Tạo đối tượng Image và lưu trữ
    if len(pixel_data_rgb) >= PIXEL_COUNT: 
        try:
            # TẠO ẢNH Ở CHẾ ĐỘ 'RGB' (3 kênh)
            img = Image.new('RGB', (IMG_WIDTH, IMG_HEIGHT))
            
            img.putdata(pixel_data_rgb[:PIXEL_COUNT])
            
            img.save(output_path, format="PNG")
            
            print(f"Thành công! Ảnh đầu ra {IMG_WIDTH}x{IMG_HEIGHT} (RGB) đã được lưu tại: {output_path}")

        except Exception as e:
            print(f"Lỗi khi tạo hoặc lưu tệp PNG: {e}")
    else:
        print(f"Lỗi: Số lượng pixel đọc được ({len(pixel_data_rgb)}) không khớp với kích thước ảnh {IMG_WIDTH}x{IMG_HEIGHT}.")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Sử dụng: python mem2png.py <tên_tệp_input.mem> <tên_tệp_output.png>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        convert_mem_to_image(input_file, output_file)