`timescale 1ns / 1ps
      
`define H_MINUS_1 10'd1023 

module adapter(
    input clk,
    input rst,
    input [2:0] op_mode,     // ĐÃ SỬA: 3-bit Operation Mode
    input [23:0] data_in,    
    output [23:0] data_out,  
    output reg jump_out,     
    output reg output_done   
);

reg [9:0] x, next_x;   
reg [9:0] y, next_y;   
reg [19:0] addr;       
reg [23:0] mem_in;       
wire [23:0] mem_out;    

// Khối tính toán hằng số W-1
localparam W_MINUS_1 = `H_MINUS_1;

// Khối Logic Tuần tự (FSM & Tăng Tọa độ)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        x <= 10'd0; 
        y <= 10'd0; 
        jump_out <= 1'b0;
        output_done <= 1'b0;
    end else begin
        x <= next_x;
        y <= next_y;
        
        jump_out <= (next_x == 10'd0) ? 1'b1 : 1'b0;

        // Hoàn thành khi quét hết ảnh VÀ không ở chế độ Store (op_mode != 3'b000)
        output_done <= (x == `H_MINUS_1 && y == `H_MINUS_1 && op_mode != 3'b000) ? 1'b1 : 1'b0;
    end
end

// Khối Logic Tổ hợp (Tính next_x và next_y - giữ nguyên)
always @(*) begin
    if (x == (`IMG_W - 1)) begin 
        next_x = 10'd0;           
        next_y = y + 1'b1;      
    end else begin
        next_x = x + 1'b1;       
        next_y = y;              
    end
end

assign mem_in = data_in;
assign data_out = mem_out;

// --- LOGIC ÁNH XẠ ĐỊA CHỈ MỚI (Sử dụng Case) ---
always @(*) begin
    case (op_mode)
        3'b000: begin // Mode 0: Store (Ghi) - {y, x}
            addr = {y, x};
        end
        3'b001: begin // Mode 1: Rotate CCW (Xoay Trái 90) - {x, H-1-y}
            addr = {x, `H_MINUS_1 - y};
        end
        3'b010: begin // Mode 2: Rotate CW (Xoay Phải 90) - {W-1-x, y}
            addr = {W_MINUS_1 - x, y};
        end
        3'b011: begin // Mode 3: Rotate 180 - {H-1-y, W-1-x}
            addr = {`H_MINUS_1 - y, W_MINUS_1 - x};
        end
        3'b100: begin // Mode 4: Mirror Horiz (Phản chiếu Ngang) - {y, W-1-x}
            addr = {y, W_MINUS_1 - x};
        end
        3'b101: begin // Mode 5: Mirror Vert (Phản chiếu Dọc) - {H-1-y, x}
            addr = {`H_MINUS_1 - y, x};
        end
        default: begin 
            addr = {y, x}; // Mặc định Ghi/Tuyến tính
        end
    endcase
end

// Khối Khởi tạo SRAM
sram ram (
    .clk(clk),
    .en(1'b1),      
    .we(op_mode == 3'b000), // WE = 1 chỉ khi op_mode = 3'b000 (Store)
    .addr(addr),
    .data_in(mem_in),
    .data_out(mem_out)
);

endmodule