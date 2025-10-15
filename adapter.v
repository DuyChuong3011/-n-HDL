`timescale 1ns / 1ps

// Các ??nh ngh?a tham s? ?nh
`define IMG_W 256
`define IMG_H 256
`define ADDR_SZ 16
`define H_MINUS_1 8'd255

module adapter(
    input clk,
    input rst,
    input mode,              // mode=0: Input/Store (Ghi vào ??a ch? tuy?n tính)
                             // mode=1: Output/Rotate (??c t? ??a ch? ?ã xoay)
    input [23:0] data_in,    // 24-bit RGB pixel input
    output [23:0] data_out,  // 24-bit RGB pixel output
    output reg jump_out,     // Tín hi?u chuy?n hàng (t? x=255 sang x=0)
    output reg output_done   // Tín hi?u hoàn thành x? lý
);

// --- Khai báo Thanh ghi N?i b? ---
reg [7:0] x, next_x;    // T?a ?? c?t (0 ??n 255)
reg [7:0] y, next_y;    // T?a ?? hàng (0 ??n 255)
reg [15:0] addr;        // 16-bit Address bus to SRAM
reg [31:0] mem_in;      // 32-bit Data In for SRAM
wire [31:0] mem_out;    // 32-bit Data Out from SRAM

// --- 1. Kh?i Logic Tu?n t? (FSM & T?ng T?a ??) ---
always @(posedge clk or posedge rst) begin
    if (rst) begin
        x <= 8'd0;
        y <= 8'd0;
        jump_out <= 1'b0;
        output_done <= 1'b0;
    end else begin
        // C?p nh?t t?a ??
        x <= next_x;
        y <= next_y;
        
        // Tín hi?u Jump Out
        // Kích ho?t khi t?a ?? chuy?n t? c?t 255 (x) sang c?t 0 (next_x)
        jump_out <= (next_x == 8'd0) ? 1'b1 : 1'b0;

        // Tín hi?u Output Done: ?ã quét h?t ?nh (x=255, y=255) VÀ ?ang ? ch? ?? Output (mode=1)
        output_done <= (x == `H_MINUS_1 && y == `H_MINUS_1 && mode == 1'b1) ? 1'b1 : 1'b0;
    end
end

// --- 2. Kh?i Logic T? h?p (Tính next_x và next_y) ---
// Logic t?ng t?a ?? tu?n t? (quét Row-Major)
always @(*) begin
    if (x == (`IMG_W - 1)) begin // N?u là c?t cu?i cùng (255)
        next_x = 8'd0;           // Chuy?n sang c?t 0
        next_y = y + 1'b1;       // T?ng hàng lên 1
    end else begin
        next_x = x + 1'b1;       // T?ng c?t lên 1
        next_y = y;              // Gi? nguyên hàng
    end
end

// --- 3. Ánh x? ??a ch? và D? li?u (Key Logic) ---

// Chuy?n ??i data_in 24-bit thành mem_in 32-bit
assign mem_in = {8'd0, data_in};

// L?y 24-bit data_out t? 32-bit mem_out
assign data_out = mem_out[23:0];

// Logic tính toán ??a ch? RAM (Addr) d?a trên MODE
// Addr là [y_addr, x_addr]
assign addr = (mode == 1'b0) ? 
              // Mode 0 (Input): ??a ch? GHI tuy?n tính (y * 256) + x
              {y, x} : 
              // Mode 1 (Output): ??a ch? ??C ?ã xoay CCW (x' = H-1-y, y' = x)
              // Ánh x? ??a ch? theo công th?c CCW: {y_m?i, x_m?i} = {x, H-1-y}
              {x, `H_MINUS_1 - y}; 

// --- 4. Kh?i Kh?i t?o SRAM ---
sram ram (
    .clk(clk),
    .en(1'b1),        // Luôn b?t enable
    .we(~mode),       // Write Enable = 0 khi mode=1 (Output/??c), Write Enable = 1 khi mode=0 (Input/Ghi)
    .addr(addr),
    .data_in(mem_in),
    .data_out(mem_out)
);

endmodule
