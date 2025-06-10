module tb();

  reg  clk;
  reg  rst_n;

  wire clk_in = clk;
  reg [31:0] cycle_count;


  wire [32-1:0] pc = cpu.reg_pc;


  // initial
  // begin
  //   $sdf_annotate("./soc_synth.sdf",zensoc,,"sdf.log","MAXIMUM");
  // end

  // 在仿真开始时给嵌套的 SRAM 初始化

  initial begin
    `include "mem_init.v"
    // $deposit(cpu.irq_state, 2'b00);
    //mul
    // $deposit(cpu.\genblk1.pcpi_mul .rs1 , 64'b0);
    // $deposit(cpu.\genblk1.pcpi_mul .rs2 , 64'b0);
    // $deposit(cpu.\genblk1.pcpi_mul .rd , 64'b0);
    // $deposit(cpu.\genblk1.pcpi_mul .rdx , 64'b0);
    // $deposit(cpu.\genblk1.pcpi_mul .rs2 , 64'b0);
    // $deposit(cpu.\genblk1.pcpi_mul .mul_counter , 7'b0);
    // $deposit(cpu.\genblk1.pcpi_mul .pcpi_wait , 1'b0);
    // $deposit(cpu.\genblk1.pcpi_mul .pcpi_wait_q , 1'b0);

    //fast_mul
    $deposit(cpu.\genblk1.pcpi_mul .rs1 , 32'b0);
    $deposit(cpu.\genblk1.pcpi_mul .rs2 , 32'b0);
    $deposit(cpu.\genblk1.pcpi_mul .shift_out , 1'b0);
    $deposit(cpu.\genblk1.pcpi_mul .active , 4'b0);

    //div
    $deposit(cpu.\genblk2.pcpi_div .instr_div , 1'b0);
    $deposit(cpu.\genblk2.pcpi_div .instr_divu , 1'b0);
    $deposit(cpu.\genblk2.pcpi_div .instr_remu , 1'b0);
    $deposit(cpu.\genblk2.pcpi_div .instr_rem , 1'b0);
    $deposit(cpu.\genblk2.pcpi_div .quotient_msk , 32'b0);


    $display("ITCM 0x00: %h", memory.u_sram.mem_array[0] );
    $display("ITCM 0x01: %h", memory.u_sram.mem_array[1] );
    $display("ITCM 0x02: %h", memory.u_sram.mem_array[2] );
    $display("ITCM 0x03: %h", memory.u_sram.mem_array[3] );
    $display("ITCM 0x04: %h", memory.u_sram.mem_array[4] );
    $display("ITCM 0x05: %h", memory.u_sram.mem_array[5] );
    $display("ITCM 0x06: %h", memory.u_sram.mem_array[6] );
    $display("ITCM 0x07: %h", memory.u_sram.mem_array[7] );
    $display("ITCM 0x16: %h", memory.u_sram.mem_array[22] );
    $display("ITCM 0x20: %h", memory.u_sram.mem_array[32] );
  end

  initial begin
    clk    = 0;      // <-- 一定要给初值
    rst_n  = 0;
    // rst_n的时间一定要大于clock的时间
    #70 rst_n = 1;   // 复位一段时间后释放
  end

  wire                       mem_valid;
  wire [31:0]                mem_addr;
  wire [31:0]                mem_wdata;
  wire [31:0]                mem_rdata;
  wire [3:0]                 mem_wstrb;
  wire                       mem_ready;
  wire                       mem_instr;
  wire                       leds_sel;
  wire                       leds_ready;
  wire [31:0]                leds_data_o;
  wire                       sram_sel;
  wire                       sram_ready;
  wire [31:0]                sram_data_o;
  wire                       uart_sel;
  wire [31:0]                uart_data_o;
  wire                       uart_ready;

   assign sram_sel = mem_valid && (mem_addr < 32'h00020000);
   assign leds_sel = mem_valid && (mem_addr == 32'h80000000);
   assign uart_sel = mem_valid && ((mem_addr & 32'hfffffff8) == 32'h80000008);
//    assign cdt_sel = mem_valid && (mem_addr == 32'h80000010);

   // Core can proceed regardless of *which* slave was targetted and is now ready.
   assign mem_ready = mem_valid & (sram_ready | leds_ready | uart_ready );
  //  | cdt_ready);


   // Select which slave's output data is to be fed to core.
   assign mem_rdata = sram_sel ? sram_data_o :
                      leds_sel ? leds_data_o :
                      uart_sel ? uart_data_o : 32'h0;
                      // cdt_sel  ? cdt_data_o  : 32'h0;

   assign leds = ~leds_data_o[3:0]; // Connect to the LEDs off the FPGA

  always @(posedge clk_in or negedge rst_n)
  begin 
    if(rst_n == 1'b0) begin
        cycle_count <= 32'b0;
    end
    else begin
        cycle_count <= cycle_count + 1'b1;
    end
  end

  // 27MHz
  // always begin
  //    #18.518 clk <= ~clk;
  // end

  // 250 MHz
  // always begin
  //     #2 clk <= ~clk;
  // end
  
  // 200 MHz
  // always begin
  //   #2.5 clk <= ~clk;
  // end

  // 150 MHz
  // always begin
  //   #3.333333 clk <= ~clk;
  // end

  // 100 MHz
  // always begin
  //     #5 clk <= ~clk;
  // end

  // 50 MHz
  // always begin
  //     #10 clk <= ~clk;
  // end

  // 10 MHz
  always begin
      #50 clk <= ~clk;
  end

  picorv32 cpu
  (
    .clk            (clk),
    .resetn         (rst_n),
    .trap           (),

    // memory 接口
    .mem_valid      (mem_valid),
    .mem_instr      (mem_instr),
    .mem_ready      (mem_ready),
    .mem_addr       (mem_addr),
    .mem_wdata      (mem_wdata),
    .mem_wstrb      (mem_wstrb),
    .mem_rdata      (mem_rdata),

    .mem_la_read    (),
    .mem_la_write   (),
    .mem_la_addr    (),
    .mem_la_wdata   (),
    .mem_la_wstrb   (),

    // PCPI 接口
    .pcpi_valid     (),
    .pcpi_insn      (),
    .pcpi_rs1       (),
    .pcpi_rs2       (),
    .pcpi_wr        (),
    .pcpi_rd        (),
    .pcpi_wait      (),
    .pcpi_ready     (),

    // IRQ 接口
    .irq            ('b0),
    .eoi            (),

    // Trace
    .trace_valid    (),
    .trace_data     ()
  );

  uart_wrap uart
  (
    .clk(clk),
    .reset_n(rst_n),
    .uart_tx(uart_tx),
    .uart_rx(uart_rx),
    .uart_sel(uart_sel),
    .addr(mem_addr[3:0]),
    .uart_wstrb(mem_wstrb),
    .uart_di(mem_wdata),
    .uart_do(uart_data_o),
    .uart_ready(uart_ready)
  );

  leds soc_leds
  (
  .clk(clk),
  .reset_n(rst_n),
  .leds_sel(leds_sel),
  .leds_data_i(mem_wdata[5:0]),
  .we(mem_wstrb[0]),
  .leds_ready(leds_ready),
  .leds_data_o(leds_data_o)
  );

  sram_wrap #(
        .ADDR_WIDTH(13),
        .BASE_ADDR(32'h0000_0000)
  ) memory
  (
    .clk(clk),
    .rst_n(rst_n),
    .mem_valid(sram_sel),
    .mem_ready(sram_ready),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_wstrb(mem_wstrb),
    .mem_rdata(sram_data_o)
  );

endmodule
