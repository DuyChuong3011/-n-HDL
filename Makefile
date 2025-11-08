# --- Cấu hình Dự án ---
# Tên các file cần thiết
VERILOG_SRC = sram.v adapter.v adapter_tb.v
INPUT_IMG = test_3.jpg
INPUT_MEM = input_test.mem
PY_CONVERT_IN = img2mem.py
PY_CONVERT_OUT = mem2png.py
VSIM_LIB = work

# Lệnh Python chính xác (Buộc gọi Python 3.14)
PYTHON_CMD = py -3.14

# Tham số mặc định cho chế độ hoạt động (00: Store, 01: Rotate CCW, 10: Mirror Horiz)
# Biến này sẽ được ghi đè từ terminal: make transform MODE=1
MODE ?= 1

# Dựa vào MODE, xác định tham số cho vsim
VSIM_ARGS = +mode=$(MODE)

# Tên file output sẽ phụ thuộc vào MODE để không bị ghi đè
OUTPUT_MEM = output_transformed.mem
OUTPUT_PNG = out_mode$(MODE).png

# Mục tiêu Chính - ALL sẽ chạy chế độ Mặc định (hoặc chế độ đã đặt)
all: $(OUTPUT_PNG)

# --- Các Pha Xử lý ---

# 1. Chuyển đổi IMG sang MEM (Pha Tiền xử lý)
$(INPUT_MEM): $(INPUT_IMG) $(PY_CONVERT_IN)
	@echo "--- 1. Convert PNG to MEM: Starting ---"
	$(PYTHON_CMD) $(PY_CONVERT_IN) $(INPUT_IMG) $(INPUT_MEM)

# 2. Chạy Mô phỏng ModelSim (Pha Xử lý Verilog)
$(OUTPUT_MEM): $(VERILOG_SRC) $(INPUT_MEM)
	@echo "--- 2. Running the ModelSim simulation: Starting with MODE=$(MODE) ---"
	vlib $(VSIM_LIB)
	vlog $(VERILOG_SRC)
	
	vsim -c $(VSIM_LIB).adapter_tb +mode=$(MODE) -do "run -all; quit"
	@echo "ModelSim finished. File $(OUTPUT_MEM) created."

# 3. Chuyển đổi MEM sang PNG (Pha Hậu xử lý)
$(OUTPUT_PNG): $(OUTPUT_MEM) $(PY_CONVERT_OUT)
	@echo "--- 3. Convert MEM to PNG: Starting ---"
	$(PYTHON_CMD) $(PY_CONVERT_OUT) $(OUTPUT_MEM) $(OUTPUT_PNG)

# --- Mục tiêu Dọn dẹp ---
clean:
# Xóa các file output (Sử dụng lệnh DEL của Windows)
	-del $(OUTPUT_MEM) $(INPUT_MEM) vsim.wlf

	-del out_mode1.png out_mode2.png out_mode3.png out_mode4.png out_mode5.png
	
# # Xóa thư mục làm việc của ModelSim (sử dụng lệnh rm -rf)
# 	-rmdir /s /q $(VSIM_LIB)
	
# Thêm mục tiêu tiện ích để Nạp ảnh (Store)
store: $(INPUT_MEM) $(VERILOG_SRC)
	@echo "--- RUNNING STORE MODE (0) ---"
	vlib $(VSIM_LIB)
	vlog $(VERILOG_SRC)
	vsim -c $(VSIM_LIB).adapter_tb +mode=0 -do "run -all; quit"
	@echo "Image data loaded into work library for later use."
	
.PHONY: all transform store clean