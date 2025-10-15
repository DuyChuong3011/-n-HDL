import sys
from PIL import Image

# Đảm bảo ảnh đầu ra có kích thước cố định 
TARGET_SIZE = (256, 256) 
# Định dạng pixel là 24-bit RGB

def convert_png_to_mem(input_path, output_path):
    try:
        # Mở ảnh và chuyển đổi sang chế độ RGB (24-bit)
        with Image.open(input_path) as img:
            # Thay đổi kích thước và đảm bảo là ảnh RGB
            img = img.resize(TARGET_SIZE).convert('RGB')
            
            # Lấy dữ liệu pixel
            pixel_data = list(img.getdata())

    except FileNotFoundError:
        print(f"Lỗi: Không tìm thấy tệp {input_path}")
        return
    except Exception as e:
        print(f"Lỗi khi xử lý ảnh: {e}")
        return

    # Ghi dữ liệu pixel ra tệp .mem
    with open(output_path, 'w') as f:
        print(f"Bắt đầu ghi {len(pixel_data)} pixel ra {output_path}...")
        
        for r, g, b in pixel_data:
            # Ghép 3 kênh 8-bit thành một giá trị 24-bit: RRRR GGGG BBBB
            # Tương đương với (R << 16) | (G << 8) | B
            rgb_value = (r << 16) | (g << 8) | b
            
            # Ghi ra tệp ở định dạng thập lục phân (hex), ModelSim đọc theo từng dòng
            # Ví dụ: ffe0c0 (Màu hồng)
            f.write(f"{rgb_value:06x}\n")

    print(f"Đã chuyển đổi thành công. Tệp .mem đã được lưu tại: {output_path}")

# Kiểm tra đầu vào
if len(sys.argv) != 3:
    print("Sử dụng: python convert_to_mem.py <đường_dẫn_tới_ảnh_input.png> <tên_tệp_output.mem>")
    # Dùng ảnh mặc định của đồ án nếu có
    # Ví dụ: python convert_to_mem.py ./res/lenna.png input_lenna.mem
else:
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    convert_png_to_mem(input_file, output_file)