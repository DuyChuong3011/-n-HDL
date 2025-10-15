import sys
from PIL import Image
import os

# --- THAM SỐ CẤU HÌNH ---
IMG_WIDTH = 256
IMG_HEIGHT = 256
PIXEL_COUNT = IMG_WIDTH * IMG_HEIGHT
# --- THAM SỐ CẤU HÌNH ---

def convert_mem_to_image(input_path, output_path):
    pixel_data = []
    
    try:
        # 1. Đọc dữ liệu Hex từ tệp .mem
        with open(input_path, 'r') as f:
            lines = f.readlines()
            
            line_count = 0
            for line in lines:
                hex_value = line.strip()
                if not hex_value:
                    continue
                
                # --- LOGIC XỬ LÝ PIXEL ---
                try:
                    # Thử chuyển đổi chuỗi hex 8-bit thành số nguyên
                    gray_int = int(hex_value, 16)
                    
                    # Giới hạn giá trị trong khoảng 0-255
                    value = gray_int & 0xFF
                
                except ValueError:
                    # Nếu chuyển đổi thất bại (do chuỗi là "xx" hoặc lỗi khác)
                    value = 0 # Gán thành Đen
                # ----------------------------------------------------
                
                # Dùng giá trị 8-bit duy nhất cho pixel Grayscale
                pixel_data.append(value)
                line_count += 1

    except FileNotFoundError:
        print(f"Lỗi: Không tìm thấy tệp .mem đầu vào tại {input_path}")
        return
    except Exception as e:
        print(f"Lỗi chung khi đọc/xử lý dữ liệu .mem: {e}")
        return

    # 2. Tạo đối tượng Image và lưu trữ
    if len(pixel_data) >= PIXEL_COUNT: 
        try:
            # Tạo đối tượng ảnh mới với chế độ 'L' (Grayscale)
            img = Image.new('L', (IMG_WIDTH, IMG_HEIGHT))
            
            img.putdata(pixel_data[:PIXEL_COUNT])
            
            # Lưu ảnh ra tệp PNG
            img.save(output_path, format="PNG")
            
            print(f"Thành công! Ảnh đầu ra {IMG_WIDTH}x{IMG_HEIGHT} (Grayscale) đã được lưu tại: {output_path}")

        except Exception as e:
            print(f"Lỗi khi tạo hoặc lưu tệp PNG: {e}")
    else:
        print(f"Lỗi: Số lượng pixel đọc được ({len(pixel_data)}) không khớp với kích thước ảnh {IMG_WIDTH}x{IMG_HEIGHT}.")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Sử dụng: python mem2png.py <tên_tệp_input.mem> <tên_tệp_output.png>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        convert_mem_to_image(input_file, output_file)