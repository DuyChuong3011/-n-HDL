`timescale 1ns / 1ps

`define IMG_W 1024    
`define IMG_H 1024    
`define RAM_DEPTH (`IMG_W * `IMG_H) 
`define ADDR_SZ 20    
`define RAM_WIDTH 24   

module sram(
    input clk, 
    input en,       
    input we,       
    input [`ADDR_SZ-1:0] addr, // Bus địa chỉ 20-bit
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