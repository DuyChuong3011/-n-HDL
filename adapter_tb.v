`timescale 1ns / 1ps

`define IMG_W 256
`define IMG_H 256
`define RAM_DEPTH (`IMG_W * `IMG_H)

module adapter_tb;

// --- Khai báo Tín hi?u Testbench ---
reg clk = 1'b0;
reg rst = 1'b1;
reg mode = 1'b0; // 0: Input/Store; 1: Output/Rotate

reg [23:0] tb_data_in;
wire [23:0] tb_data_out;
wire jump_out;
wire output_done;

// --- Khai báo M?ng B? nh? và Bi?n ??m ---
reg [23:0] input_mem [`RAM_DEPTH-1:0]; 
integer i = 0;
integer output_index = 0; 

// File Descriptor cho vi?c ghi file
integer output_file;

// K?t n?i v?i Module Adapter (UUT: Unit Under Test)
adapter UUT (
    .clk(clk),
    .rst(rst),
    .mode(mode),
    .data_in(tb_data_in),
    .data_out(tb_data_out),
    .jump_out(jump_out),
    .output_done(output_done)
);

// --- 1. T?o Clock và Reset ---
always #10 clk = ~clk;

initial begin
    $display("--- Start Image Rotation Simulation ---");
    rst = 1'b1;
    mode = 1'b0; 
    tb_data_in = 24'h000000;
    #20;
    rst = 1'b0;
end

// --- 2. Giai ?o?n Mô ph?ng chính ---
initial begin
    
    // N?p d? li?u ?nh t? file .mem (File ph?i ch?a 24-bit Hex)
    $readmemh("input_test.mem", input_mem); 
    
    @(negedge rst); 

    // --- PHASE 1: N?p ?nh vào SRAM (mode=0, Ghi) ---
    $display("Phase 1: Loading %dx%d image into SRAM (Mode=0)...", `IMG_W, `IMG_H);
    mode = 1'b0; 
    
    // N?p 65536 pixel (ho?c RAM_DEPTH)
    for (i = 0; i < `RAM_DEPTH; i = i + 1) begin
        @(posedge clk) begin
            tb_data_in = input_mem[i];
        end
    end
    
    $display("Load Complete. Starting Output Phase...");

    // --- PHASE 2: B?t ??u Xoay và Xu?t ?nh (mode=1) ---
    #50; // Delay nh? ?? ?n ??nh
    
    // Chuy?n sang ch? ?? Output/Rotate (mode=1)
    mode = 1'b1; 
    output_index = 0;
    
    // M? file output ch? ?? ghi raw hex data
    output_file = $fopen("output_rotated.mem", "w");
    if (output_file == 0) begin
        $display("ERROR: Could not open output_rotated.mem for writing.");
        $finish;
    end
    $display("Phase 2: Rotation started. Writing raw pixel data...");

    // Vòng l?p chính ?? ??c pixel ?ã xoay và ghi vào file
    while (output_index < `RAM_DEPTH) begin
        @(posedge clk) begin
            // Ghi d? li?u 24-bit (6 ký t? hex) tr?c ti?p vào file.
            // %h: Hexadecimal format
            // $fdisplay t? ??ng thêm ký t? xu?ng dòng sau m?i pixel.
            $fdisplay(output_file, "%h", tb_data_out); 
            
            output_index = output_index + 1;

            // Ki?m tra tín hi?u hoàn thành
            if (output_done) begin
                $display("Rotation Complete. Final pixel read.");
                output_index = `RAM_DEPTH; // Thoát vòng l?p
            end
        end
    end // end while loop

    // ?óng file và k?t thúc mô ph?ng
    @(posedge clk) begin
        $fclose(output_file);
        $display("--- Output (raw pixel data) saved successfully to output_rotated.mem ---");
        $finish;
    end
end // end initial

endmodule