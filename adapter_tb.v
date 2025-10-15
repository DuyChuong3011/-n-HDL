`timescale 1ns / 1ps

`define IMG_W 256
`define IMG_H 256
`define RAM_DEPTH (`IMG_W * `IMG_H)

module adapter_tb;

// --- Declare Top-level ---
reg clk = 1'b0;
reg rst = 1'b1;
reg mode = 1'b0; 

reg [7:0] tb_data_in;    
wire [7:0] tb_data_out;   
wire jump_out;
wire output_done;

// Declare Integer and File Descriptor at Top-level
reg [7:0] input_mem [`RAM_DEPTH-1:0]; 
integer output_file;
integer i;
integer output_index;

//Connect to the Adapter Module (UUT)
adapter UUT (
    .clk(clk),
    .rst(rst),
    .mode(mode),
    .data_in(tb_data_in),
    .data_out(tb_data_out),
    .jump_out(jump_out),
    .output_done(output_done)
);

// --- 1. Create Clock and Reset ---
always #10 clk = ~clk;

initial begin
    // Khởi tạo biến Integer trong initial block
    i = 0; 
    
    rst = 1'b1;
    mode = 1'b0; 
    tb_data_in = 8'h00; 
    #20;
    rst = 1'b0;
end

// --- 2. Main Simulation Phase ---
initial begin
    
    // Load image data from the .mem file 
    $readmemh("input_test.mem", input_mem); 
    
    @(negedge rst); 

    // --- PHASE 1: Load image into SRAM (mode=0, Write) ---
    mode = 1'b0; 
    
    for (i = 0; i < `RAM_DEPTH; i = i + 1) begin
        @(posedge clk) begin
            tb_data_in = input_mem[i];
        end
    end

    // --- PHASE 2: Start Rotating and Outputting the Image (mode=1) ---
    #50; 
    
    mode = 1'b1; 
    output_index = 0;
    
    // Open the output file only to write raw hex data
    output_file = $fopen("output_rotated.mem", "w");
    
    // Main loop to read rotated pixels and write to file
    for (output_index = 0; output_index < `RAM_DEPTH; output_index = output_index + 1) begin
        @(posedge clk) begin
            // Write 8-bit data (2 hex characters) directly to the file.
            $fdisplay(output_file, "%h", tb_data_out); 
        end
    end 
    
    // Close the file and end the simulation.
    @(posedge clk) begin
        $fclose(output_file);
        $finish;
    end
end

endmodule