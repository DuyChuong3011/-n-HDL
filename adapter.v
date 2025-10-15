`timescale 1ns / 1ps

`define IMG_W 512
`define IMG_H 512
`define ADDR_SZ 18        // 18 bit
`define H_MINUS_1 9'd511 // 511 (9 bit)

module adapter(
    input clk,
    input rst,
    input mode,              
    input [7:0] data_in,    
    output [7:0] data_out,  
    output reg jump_out,     
    output reg output_done   
);

// Bus tọa độ 9 bit (0-511)
reg [8:0] x, next_x;   
reg [8:0] y, next_y;   
reg [17:0] addr;       // 18 bit
reg [7:0] mem_in;       
wire [7:0] mem_out;    

// Khối Logic Tuần tự (FSM & Tăng Tọa độ)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        x <= 9'd0; 
        y <= 9'd0; 
        jump_out <= 1'b0;
        output_done <= 1'b0;
    end else begin
        x <= next_x;
        y <= next_y;
        
        jump_out <= (next_x == 9'd0) ? 1'b1 : 1'b0;

        // Hoàn thành khi quét hết ảnh (x=511, y=511)
        output_done <= (x == `H_MINUS_1 && y == `H_MINUS_1 && mode == 1'b1) ? 1'b1 : 1'b0;
    end
end

// Khối Logic Tổ hợp (Tính next_x và next_y)
always @(*) begin
    if (x == (`IMG_W - 1)) begin 
        next_x = 9'd0;           
        next_y = y + 1'b1;      
    end else begin
        next_x = x + 1'b1;       
        next_y = y;              
    end
end

// Ánh xạ Địa chỉ và Dữ liệu
assign mem_in = data_in;
assign data_out = mem_out;

// Logic tính toán Địa chỉ RAM: Quay lại dùng Nối bit (Concatenation)
// Addr = {y, x}
// Xoay CCW: Addr = {x, H-1-y}
assign addr = (mode == 1'b0) ? 
              {y, x} : 
              {x, `H_MINUS_1 - y}; 

// Khối Khởi tạo SRAM
sram ram (
    .clk(clk),
    .en(1'b1),      
    .we(~mode),     
    .addr(addr),
    .data_in(mem_in),
    .data_out(mem_out)
);

endmodule