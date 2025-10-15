`timescale 1ns / 1ps

`define IMG_W 256
`define IMG_H 256
`define RAM_DEPTH (`IMG_W * `IMG_H) 
`define ADDR_SZ 16 
`define RAM_WIDTH 8 // Bus RAM 8-bit

module sram(
    input clk, 
    input en,       
    input we,       
    input [`ADDR_SZ-1:0] addr, 
    input [`RAM_WIDTH-1:0] data_in,
    output reg [`RAM_WIDTH-1:0] data_out
);

reg [`RAM_WIDTH-1:0] mem [`RAM_DEPTH-1:0];

always @(posedge clk) begin // ĐÃ SỬA LỖI: Thêm begin
    if (en) begin
        if (we) begin       
            mem[addr] <= data_in;
        end else begin      
            data_out <= mem[addr];
        end
    end
end // ĐÃ SỬA LỖI: Thêm end

endmodule