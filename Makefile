# --- Cấu hình Dự án ---
# Tên các file cần thiết
VERILOG_SRC = sram.v adapter.v adapter_tb.v
INPUT_PNG = hcmut.png
INPUT_MEM = input_test.mem
OUTPUT_MEM = output_rotated.mem
OUTPUT_PNG = out_test.png
PY_CONVERT_IN = png2mem.py
PY_CONVERT_OUT = mem2png.py
VSIM_LIB = work

# Lệnh Python chính xác (Buộc gọi Python 3.14)
PYTHON_CMD = py -3.14

# --- Mục tiêu Chính ---
all: $(OUTPUT_PNG)

# --- Các Pha Xử lý ---

# 1. Chuyển đổi MEM sang PNG (Pha Hậu xử lý)
$(OUTPUT_PNG): $(OUTPUT_MEM) $(PY_CONVERT_OUT)
	@echo "--- 3. Convert MEM to PNG: Starting ---"
	$(PYTHON_CMD) $(PY_CONVERT_OUT) $(OUTPUT_MEM) $(OUTPUT_PNG)

# 2. Chạy Mô phỏng ModelSim (Pha Xử lý Verilog)
$(OUTPUT_MEM): $(VERILOG_SRC) $(INPUT_MEM)
	@echo "--- 2. Running the ModelSim simulation: Starting ---"
	vlib $(VSIM_LIB)
	vlog $(VERILOG_SRC)
	vsim -c $(VSIM_LIB).adapter_tb -do "run -all; quit"
	@echo "ModelSim finished. File $(OUTPUT_MEM) created."

# 3. Chuyển đổi PNG sang MEM (Pha Tiền xử lý)
$(INPUT_MEM): $(INPUT_PNG) $(PY_CONVERT_IN)
	@echo "--- 1. Convert PNG to MEM: Starting ---"
	$(PYTHON_CMD) $(PY_CONVERT_IN) $(INPUT_PNG) $(INPUT_MEM)

# --- Mục tiêu Dọn dẹp ---
clean:
# Xóa các file (sử dụng lệnh rm -f)
	-rm -f $(OUTPUT_PNG) $(OUTPUT_MEM) $(INPUT_MEM) vsim.wlf
	
# Xóa thư mục làm việc của ModelSim (sử dụng lệnh rm -rf)
	-rm -rf $(VSIM_LIB)
	
.PHONY: all clean