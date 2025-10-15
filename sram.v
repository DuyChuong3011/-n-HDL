`timescale 1ns / 1ps

`define IMG_W 512     // Kích thước ảnh 512
`define IMG_H 512     // Kích thước ảnh 512
`define RAM_DEPTH 262144 // 512 * 512
`define ADDR_SZ 18    // 18 bit địa chỉ (2^18)
`define RAM_WIDTH 8   // Grayscale 8-bit

module sram(
    input clk, 
    input en,       
    input we,       
    input [`ADDR_SZ-1:0] addr, // Bus địa chỉ 18-bit
    input [`RAM_WIDTH-1:0] data_in,
    output reg [`RAM_WIDTH-1:0] data_out
);

reg [`RAM_WIDTH-1:0] mem [`RAM_DEPTH-1:0];

always @(posedge clk) begin
    if (en) begin
        if (we) begin       
            mem[addr] <= data_in;
        end else begin      
            data_out <= mem[addr];
        end
    end
end

endmodule