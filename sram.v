`timescale 1ns / 1ps

// ??nh ngh?a tham s? ?nh
`define IMG_W 256
`define IMG_H 256
`define RAM_DEPTH (`IMG_W * `IMG_H) // 65536 ô nh?
`define ADDR_SZ 16 // log2(65536) = 16 bit ??a ch?
`define RAM_WIDTH 32 // Chi?u r?ng 32-bit (ch?a pixel 24-bit RGB)

module sram(
    input clk, 
    input en,       // Enable (th??ng n?i c?ng '1')
    input we,       // Write Enable (we = ~mode trong adapter)
    input [`ADDR_SZ-1:0] addr, 
    input [`RAM_WIDTH-1:0] data_in,
    output reg [`RAM_WIDTH-1:0] data_out
);

// Khai báo m?ng b? nh? (RAM)
reg [`RAM_WIDTH-1:0] mem [`RAM_DEPTH-1:0];

// Kh?i logic ??ng b? cho RAM
always @(posedge clk) begin
    if (en) begin
        if (we) begin       // WE = 1: Ghi d? li?u
            mem[addr] <= data_in;
        end else begin      // WE = 0: ??c d? li?u
            data_out <= mem[addr];
        end
    end
end

endmodule