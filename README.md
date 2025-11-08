# ⚙️ LOGIC DESIGN PROJECT (251): RGB IMAGE TRANSFORMATION ACCELERATOR

## 1. Tóm tắt Hệ thống

Dự án này là thiết kế Verilog HDL cho một bộ tăng tốc phần cứng (Hardware Accelerator) để thực hiện các phép biến đổi hình học trên ảnh số. Hệ thống đã được nâng cấp để xử lý ảnh **RGB 24-bit** với độ phân giải cao **1024 x 1024** (1 Megapixel), vượt tiêu chuẩn 720p.

### Thông số Kỹ thuật Chính

| Thông số | Giá trị | Ý nghĩa |
| :--- | :--- | :--- |
| **Độ phân giải** | 1024 x 1024 | Kích thước ảnh đầu cuối. |
| **Độ sâu Màu** | RGB 24-bit | 8 bit/kênh (R, G, B) để giữ nguyên màu sắc. |
| **Bus Địa chỉ** | 20-bit | Cần thiết để truy cập 1,048,576 ô nhớ. |
| **Cốt lõi** | Ánh xạ Địa chỉ (Address Remapping) | Thuật toán xoay và phản chiếu được thực thi bằng logic địa chỉ. |

---

## 2. Các Chế độ Hoạt động (Operation Modes)

Module `adapter.v` được điều khiển bằng bus **`op_mode` (3-bit)**, được truyền qua terminal bằng tham số `+mode=X`.

| `MODE`        | Tên                            | Phép toán | Công thức Ánh xạ (Address Mapping) |
| **0** (`000`) | **Store** (Ghi) | - | $\{\mathbf{y}, \mathbf{x}\}$ |
| **1** (`001`) | **Rotate CCW** (Xoay Trái 90°) | $(H-1-y, x)$ | $\{\mathbf{x}, \mathbf{H-1-y}\}$ |
| **2** (`010`) | **Rotate CW** (Xoay Phải 90°) | $(y, W-1-x)$ | $\{\mathbf{W-1-x}, \mathbf{y}\}$ |
| **3** (`011`) | **Rotate 180°** | $(W-1-x, H-1-y)$ | $\{\mathbf{H-1-y}, \mathbf{W-1-x}\}$ |
| **4** (`100`) | **Mirror Horiz** (Phản chiếu Ngang) | $(W-1-x, y)$ | $\{\mathbf{y}, \mathbf{W-1-x}\}$ |
| **5** (`101`) | **Mirror Vert** (Phản chiếu Dọc) | $(x, H-1-y)$ | $\{\mathbf{H-1-y}, \mathbf{x}\}$ |

---

## 3. Hướng dẫn Vận hành Chương trình

Quy trình chạy tự động hóa bằng `Makefile` và yêu cầu chạy lệnh `make` trong môi trường Bash (Git Bash/MinGW).

### A. Chuẩn bị

1.  **Môi trường:** Đảm bảo `make`, `python3.14` (Pillow), và các lệnh ModelSim (`vlib`, `vlog`, `vsim`) có thể truy cập được từ terminal.
2.  **Ảnh Input:** Đặt ảnh đầu vào (`hcmut.png`, `my_image.jpg`, v.v.) vào thư mục dự án.

### B. Lệnh Thực thi Chính

Sử dụng lệnh `make all MODE=X` để chạy tự động 3 pha (Convert IMG --> Simulate --> Convert PNG).

| Lệnh Thực thi         | Chế độ         | Ý nghĩa |
| **`make all MODE=1`** | **Rotate CCW** | Chạy toàn bộ quy trình Xử lý, xuất file **`out_mode1.png`**. |
| **`make all MODE=3`** | **Rotate 180°** | Chạy toàn bộ quy trình Xử lý, xuất file **`out_mode3.png`**. |
| **`make store`** | **Store** (Chỉ Ghi) | Chỉ chạy Pha Ghi (`+mode=0`) để nạp dữ liệu vào SRAM ảo, sau đó dừng. |

**Quy trình Xử lý (Ví dụ: `MODE=1`):**

1.  **Pha 1 (Input):** Python (`img2mem.py`) chuyển đổi ảnh $\rightarrow$ RGB $\rightarrow$ Độn viền $\rightarrow$ Xuất ra file `input_test.mem` (24-bit HEX).
2.  **Pha 2 (Verilog):** ModelSim chạy Pha Ghi (Store) $\rightarrow$ Pha Xử lý (Rotate) $\rightarrow$ Ghi kết quả 24-bit vào `output_transformed.mem`.
3.  **Pha 3 (Output):** Python (`mem2png.py`) đọc 24-bit HEX $\rightarrow$ Tái tạo và lưu ảnh màu **RGB** kết quả.

---

## 4. Quản lý File (Maintenance Commands)

| Lệnh | Chức năng |
| :--- | :--- |
| **`make clean`** | Xóa tất cả các file trung gian và output (`.mem`, `.png`, thư mục `work`). |
| **`make store`** | Chạy Pha Ghi dữ liệu độc lập vào SRAM mô phỏng. |