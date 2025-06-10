/*
 * Wrapper to map PicoRV32 memory interface into SRAM module
 */
module sram_wrap #(
    parameter ADDR_WIDTH = 13,
    parameter BASE_ADDR  = 32'h0000_0000
)(
    input  wire        clk,
    input  wire        rst_n,
    // PicoRV32 native memory interface
    input  wire        mem_valid,
    // input  wire        mem_instr,
    output wire        mem_ready,
    input  wire [31:0] mem_addr,
    input  wire [31:0] mem_wdata,
    input  wire [ 3:0] mem_wstrb,
    output wire [31:0] mem_rdata
);

    // Select this SRAM when address is within range
    localparam BYTE_DEPTH = (1 << ADDR_WIDTH) * 4;
    wire         sel = mem_valid &&
                       (mem_addr >= BASE_ADDR) &&
                       (mem_addr <  BASE_ADDR + BYTE_DEPTH);

    // Signals for the SRAM instance
    wire        sram_ready;
    wire [31:0] sram_rdata;

    sram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .BASE_ADDR (BASE_ADDR)
    ) u_sram (
        .clk       (clk),
        .rst_n       (rst_n),
        .mem_valid (sel),
        // .mem_instr (mem_instr),
        .mem_ready (sram_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (sram_rdata)
    );

    // Output back to PicoRV32
    assign mem_ready = sel ? sram_ready : 1'b0;
    assign mem_rdata = sel ? sram_rdata : 32'b0;

endmodule
