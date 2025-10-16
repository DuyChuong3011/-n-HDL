`timescale 1ns / 1ps

`define IMG_W 1024
`define IMG_H 1024
`define RAM_DEPTH (`IMG_W * `IMG_H) // 1048576

module adapter_tb;

// --- Khai báo Tín hiệu Testbench ---
reg clk = 1'b0;
reg rst = 1'b1;
reg mode = 1'b0; 

reg [7:0] tb_data_in;    
wire [7:0] tb_data_out;   
wire jump_out;
wire output_done;

// --- Khai báo Mảng Bộ nhớ và Biến Đếm ---
reg [7:0] input_mem [`RAM_DEPTH-1:0]; // 1024*1024 phần tử
integer output_file;
integer i;
integer output_index;

// Kết nối với Module Adapter (UUT)
adapter UUT (
    .clk(clk),
    .rst(rst),
    .mode(mode),
    .data_in(tb_data_in),
    .data_out(tb_data_out),
    .jump_out(jump_out),
    .output_done(output_done)
);

// --- 1. Tạo Clock và Reset ---
always #10 clk = ~clk;

initial begin
    i = 0; 
    output_index = 0;
    
    rst = 1'b1;
    mode = 1'b0; 
    tb_data_in = 8'h00; 
    #20;
    rst = 1'b0;
end

// --- 2. Giai đoạn Mô phỏng chính ---
initial begin
    
    // Nạp dữ liệu ảnh từ file .mem 
    $readmemh("input_test.mem", input_mem); 
    
    @(negedge rst); 

    // --- PHASE 1: Nạp ảnh vào SRAM ---
    mode = 1'b0; 
    
    // Nạp 1.048.576 pixel
    for (i = 0; i < `RAM_DEPTH; i = i + 1) begin
        @(posedge clk) begin
            tb_data_in = input_mem[i];
        end
    end

    // --- PHASE 2: Bắt đầu Xoay và Xuất ảnh ---
    #50; 
    
    mode = 1'b1; 
    
    // Mở file output
    output_file = $fopen("output_rotated.mem", "w");
    
    // Vòng lặp chính để đọc pixel đã xoay và ghi vào file
    for (output_index = 0; output_index < `RAM_DEPTH; output_index = output_index + 1) begin
        @(posedge clk) begin
            $fdisplay(output_file, "%h", tb_data_out); 
        end
    end 
    
    // Đóng file và kết thúc mô phỏng
    @(posedge clk) begin
        $fclose(output_file);
        $finish;
    end
end

endmodule