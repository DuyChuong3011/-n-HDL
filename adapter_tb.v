`timescale 1ns / 1ps

`define IMG_W 1024
`define IMG_H 1024
`define RAM_DEPTH (`IMG_W * `IMG_H) // 1048576

module adapter_tb;

// --- Khai báo Tín hiệu Testbench ---
reg clk = 1'b0;
reg rst = 1'b1;
reg [1:0] op_mode; 
reg [7:0] tb_data_in;    
wire [7:0] tb_data_out;   
wire jump_out;
wire output_done;

// --- Khai báo Mảng Bộ nhớ và Biến Đếm ---
reg [7:0] input_mem [`RAM_DEPTH-1:0]; 
integer output_file;
integer i;
integer output_index;

// Biến cho $value$plusargs
integer mode_val = 0; 
integer scan_ok; 


// Kết nối với Module Adapter (UUT)
adapter UUT (
    .clk(clk),
    .rst(rst),
    .op_mode(op_mode), 
    .data_in(tb_data_in),
    .data_out(tb_data_out),
    .jump_out(jump_out),
    .output_done(output_done)
);

// --- 1. Tạo Clock và Reset ---
always #10 clk = ~clk;

// Khối khởi tạo / Đọc tham số
initial begin
    // 1. Đọc tham số MODE từ terminal
    scan_ok = $value$plusargs("mode=%d", mode_val);
    
    if (scan_ok) begin
        op_mode = mode_val;
    end else begin
        op_mode = 2'b00; // Mặc định là Store/Ghi
    end
    
    // 2. Thiết lập Reset
    i = 0; 
    output_index = 0;
    rst = 1'b1;
    tb_data_in = 8'h00; 
    #20;
    rst = 1'b0;
    
    $display("Testbench initialized. Mode: %b", op_mode);
end


// --- 2. Giai đoạn Mô phỏng chính ---
initial begin
    
    // Nạp dữ liệu ảnh từ file .mem vào mảng
    $readmemh("input_test.mem", input_mem); 
    
    @(negedge rst); 

    // -----------------------------------------------------------------
    // LOGIC CHÍNH: Xử lý Ghi và Đọc/Xoay trong cùng một lần chạy vsim
    // -----------------------------------------------------------------
    
    if (op_mode == 2'b00) begin
        // --- PHA 1A: CHẾ ĐỘ GHI DỮ LIỆU (STORE) ---
        $display("PHASE 1A: Running Store (00) - Loading 1M Pixels...");
        
        for (i = 0; i < `RAM_DEPTH; i = i + 1) begin
            @(posedge clk) tb_data_in = input_mem[i];
        end
        
        $display("Store Complete. Image data is now in SRAM.");
        $finish; // Kết thúc mô phỏng nếu CHỈ muốn Nạp ảnh
    end
    
    else begin
        // --- PHA 1B: BUỘC GHI LẠI ẢNH (STORE) TRƯỚC KHI XỬ LÝ ---
        $display("PHASE 1B: Running Store (00) internally to ensure data integrity...");
        
        // Ghi chú: op_mode đã là chế độ xử lý (01 hoặc 10). Phải tạm thời chuyển về 00 để ghi.
        op_mode = 2'b00; 
        
        for (i = 0; i < `RAM_DEPTH; i = i + 1) begin
            @(posedge clk) tb_data_in = input_mem[i];
        end
        
        // --- KHẮC PHỤC LỖI MẤT DỮ LIỆU: Đảm bảo đồng bộ hóa Ghi/Đọc ---
        // Thêm 2 chu kỳ clock delay để đảm bảo pixel cuối cùng đã được ghi vào SRAM
        #20; 
        
        // Chuyển lại chế độ xử lý ban đầu (đọc lại giá trị từ $plusargs)
        $value$plusargs("mode=%d", mode_val); 
        op_mode = mode_val; 
        
        $display("Store Complete. PHASE 2: Transformation Mode Activated: %b. Starting read cycle...", op_mode);


        // --- PHA 2: CHẾ ĐỘ XỬ LÝ (ROTATE/MIRROR) ---
        
        // Mở file output
        output_file = $fopen("output_transformed.mem", "w");
        
        // Vòng lặp chính để đọc pixel đã xoay và ghi vào file
        for (output_index = 0; output_index < `RAM_DEPTH; output_index = output_index + 1) begin
            @(posedge clk) $fdisplay(output_file, "%h", tb_data_out); 
        end 
        
        @(posedge clk) begin
            $fclose(output_file);
            $display("Transformation Complete. Output saved to output_transformed.mem");
            $finish;
        end
    end
    
end
endmodule