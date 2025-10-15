import sys
from PIL import Image
import os

# Tham số cố định của đồ án
IMG_WIDTH = 256
IMG_HEIGHT = 256
PIXEL_COUNT = IMG_WIDTH * IMG_HEIGHT

def convert_mem_to_image(input_path, output_path):
    pixel_data = []
    
    try:
        # 1. Đọc dữ liệu Hex từ tệp .mem
        with open(input_path, 'r') as f:
            lines = f.readlines()
            
            # Kiểm tra số lượng pixel đọc được so với tổng số pixel yêu cầu
            # Vẫn chạy tiếp dù có lỗi, nhưng sẽ báo lỗi nếu số lượng không khớp cuối cùng
            
            line_count = 0
            for line in lines:
                hex_value = line.strip()
                if not hex_value:
                    continue
                
                # --- LOGIC GÁN CỨNG PIXEL ĐẦU TIÊN (000000) ---
                if line_count == 0:
                    # Pixel đầu tiên luôn được gán là trắng
                    # r, g, b = 0xFF, 0xFF, 0xFF
                    r, g, b = 0, 0, 0
                    pixel_data.append((r, g, b))
                else:
                    # --- XỬ LÝ CÁC DÒNG CÒN LẠI (Kiểm tra 'X' và đọc Hex) ---
                    try:
                        # Thử chuyển đổi chuỗi hex thành số nguyên
                        rgb_int = int(hex_value, 16)
                        
                        # Tách 24-bit thành 3 kênh 8-bit (R, G, B)
                        r = (rgb_int >> 16) & 0xFF
                        g = (rgb_int >> 8) & 0xFF
                        b = rgb_int & 0xFF
                    
                    except ValueError:
                        # Nếu chuyển đổi thất bại (do chuỗi là "xxxxxx" hoặc chứa 'z')
                        # Gán pixel đó thành màu Đen (000000)
                        r, g, b = 0, 0, 0
                # ----------------------------------------------------
                
                pixel_data.append((r, g, b))
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
            # Tạo đối tượng ảnh mới với chế độ RGB và kích thước
            img = Image.new('RGB', (IMG_WIDTH, IMG_HEIGHT))
            
            # Ghi dữ liệu pixel đã đọc vào ảnh (chỉ lấy PIXEL_COUNT)
            img.putdata(pixel_data[:PIXEL_COUNT])
            
            # Lưu ảnh ra tệp PNG
            img.save(output_path, format="PNG")
            
            print(f"Thành công! Ảnh đầu ra đã được lưu tại: {output_path}")

        except Exception as e:
            print(f"Lỗi khi tạo hoặc lưu tệp PNG: {e}")
    else:
        print(f"Lỗi: Số lượng pixel đọc được ({len(pixel_data)}) không khớp với kích thước ảnh {IMG_WIDTH}x{IMG_HEIGHT}.")


# --- Kiểm tra và chạy chương trình ---
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Sử dụng: python convert_mem_to_png.py <tên_tệp_input.mem> <tên_tệp_output.png>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        convert_mem_to_image(input_file, output_file)