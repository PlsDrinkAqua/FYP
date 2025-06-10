/*
 * Simple SRAM module for PicoRV32 native memory interface
 */
module sram #(
    parameter ADDR_WIDTH = 13,              // Address width in words (depth = 2**ADDR_WIDTH)
    parameter BASE_ADDR  = 32'h0000_0000    // Base address of this SRAM
)(
    input  wire           clk,
    input  wire           rst_n,            // synchronous reset (active low)
    // PicoRV32 native memory interface
    input  wire           mem_valid,
    // input  wire           mem_instr,
    output reg            mem_ready,
    input  wire [31:0]    mem_addr,
    input  wire [31:0]    mem_wdata,
    input  wire [ 3:0]    mem_wstrb,
    output reg  [31:0]    mem_rdata
);

    // Memory array: 32-bit words
    localparam DEPTH = (1 << ADDR_WIDTH);
    reg [31:0] mem_array [0:DEPTH-1];
    `include "mem_init.v"
    // Word-aligned address (drop low 2 bits)
    wire [ADDR_WIDTH-1:0] addr_word = (mem_addr - BASE_ADDR) >> 2;

    // Combined synchronous read/write and ready logic
    always @(posedge clk) begin
        if (!rst_n) begin
            mem_ready <= 1'b0;
            mem_rdata <= 32'b0;
        end else begin
            // Ready goes high whenever a valid transaction is seen
            mem_ready <= mem_valid;

            if (mem_valid) begin
                if (mem_wstrb == 4'b0000) begin
                    // Read operation: latch read data
                    mem_rdata <= mem_array[addr_word];
                end else begin
                    // Write operation: byte-enable write
                    if (mem_wstrb[3]) mem_array[addr_word][ 7: 0] <= mem_wdata[ 7: 0];
                    if (mem_wstrb[2]) mem_array[addr_word][15: 8] <= mem_wdata[15: 8];
                    if (mem_wstrb[1]) mem_array[addr_word][23:16] <= mem_wdata[23:16];
                    if (mem_wstrb[0]) mem_array[addr_word][31:24] <= mem_wdata[31:24];
                end
            end
        end
    end
endmodule