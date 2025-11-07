# ⚙️ LOGIC DESIGN PROJECT (251): IMAGE TRANSFORMATION ACCELERATOR

## 1. Tóm tắt Hệ thống

Dự án này là việc thiết kế và mô phỏng một bộ tăng tốc phần cứng (Hardware Accelerator) sử dụng Verilog HDL để thực hiện các phép biến đổi hình học trên ảnh số.

Thiết kế sử dụng mô hình RAM đồng bộ để lưu trữ và xử lý ảnh **Grayscale 8-bit** với độ phân giải cao **1024 x 1024** (1 Megapixel), vượt tiêu chuẩn 720p.

### Thông số Kỹ thuật Chính

| Thông số | Giá trị | Ý nghĩa |
| :--- | :--- | :--- |
| **Độ phân giải** | 1024 x 1024 |
| **Độ sâu Màu** | Grayscale 8-bit | Mỗi pixel có giá trị từ 0 đến 255. |
| **Bus Địa chỉ** | 20-bit | Cần thiết để truy cập 1,048,576 ô nhớ. |
| **Ngôn ngữ** | Verilog HDL | Thiết kế mạch logic số. |
| **Công cụ Mô phỏng** | ModelSim / QuestaSim | Môi trường kiểm tra chức năng. |

---

## 2. Các Chế độ Hoạt động (Operation Modes)

Module `adapter.v` được điều khiển bằng bus **`op_mode` (2-bit)**, được truyền qua terminal bằng tham số `+mode=X`.

| `MODE` | Tên | Chế độ | Công thức Ánh xạ (Address Mapping) |
| :--- | :--- | :--- | :--- |
| **0** (`2'b00`) | **Store** | Ghi dữ liệu ảnh vào SRAM. | $\{\mathbf{y}, \mathbf{x}\}$ |
| **1** (`2'b01`) | **Rotate CCW** | Xoay 90° Ngược chiều kim đồng hồ. | $\{\mathbf{x}, \mathbf{1023 - y}\}$ |
| **2** (`2'b10`) | **Mirror Horiz** | Phản chiếu Ngang. | $\{\mathbf{y}, \mathbf{1023 - x}\}$ |

---

## 3. Hướng dẫn Vận hành Chương trình

Quy trình chạy được tự động hóa bằng `Makefile` và yêu cầu chạy lệnh `make` trong môi trường Bash (Git Bash/MinGW).

### A. Chuẩn bị

1.  **Môi trường:** Đảm bảo `make`, `python3` (với thư viện Pillow), và các lệnh ModelSim (`vlib`, `vlog`, `vsim`) có thể truy cập được từ terminal.
2.  **Ảnh Input:** Đặt ảnh đầu vào (`hcmut.png`, `my_image.jpg`, v.v.) vào thư mục dự án.

### B. Lệnh Thực thi Chính

Lệnh chạy tự động 3 pha (Convert IMG → Simulate → Convert PNG).

| Lệnh Thực thi | Mô tả |
| :--- | :--- |
| **`make all MODE=1`** | **Chế độ Mặc định (Rotate CCW):** Chạy toàn bộ quy trình Xử lý (Store $\rightarrow$ Rotate), xuất file **`out_mode1.png`**. |
| **`make all MODE=2`** | **Phản chiếu Ngang:** Chạy toàn bộ quy trình Xử lý, xuất file **`out_mode2.png`**. |
| **`make store`** | **Chỉ Nạp ảnh (Store):** Chỉ chạy Pha Ghi (`+mode=0`) để lưu dữ liệu vào thư viện ModelSim. |

**Quy trình Xử lý (Ví dụ: `MODE=1`):**

1.  **Pha 1 (Input):** Python chuyển đổi ảnh $\rightarrow$ Grayscale $\rightarrow$ Xuất ra file `.mem`.
2.  **Pha 2 (Verilog):** ModelSim chạy logic Verilog, thực hiện Pha Ghi (Store) $\rightarrow$ Pha Xử lý (Rotate) $\rightarrow$ Ghi kết quả vào `output_transformed.mem`.
3.  **Pha 3 (Output):** Python đọc `output_transformed.mem` $\rightarrow$ Tái tạo và lưu ảnh kết quả.

---

## 4. Phân công Module

| File | Chức năng | Cốt lõi |
| :--- | :--- | :--- |
| **`sram.v`** | Bộ nhớ | Lưu trữ dữ liệu Grayscale 8-bit. |
| **`adapter.v`** | Controller/FSM | Chứa logic ánh xạ địa chỉ và điều khiển quét ảnh. |
| **`adapter_tb.v`** | Testbench | Điều khiển luồng Ghi $\rightarrow$ Đọc/Xử lý, dùng `$value$plusargs`. |
| **`img2mem.py`** | Tiền xử lý | Chuyển đổi PNG/JPG $\rightarrow$ Grayscale $\rightarrow$ Độn viền $\rightarrow$ File `.mem`. |
| **`mem2png.py`** | Hậu xử lý | Đọc file `.mem` thô $\rightarrow$ Tái tạo ảnh PNG. |