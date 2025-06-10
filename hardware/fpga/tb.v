module tb_top();

  reg  clk;
  reg  lfextclk;
  reg  rst_n;

  wire clk_in = clk;
  reg [31:0] cycle_count;


  wire [32-1:0] pc = zensoc.cpu.reg_pc;

initial begin
  clk    = 0;      // <-- 一定要给初值
  rst_n  = 0;
  #20 rst_n = 1;   // 复位一段时间后释放
end



  always @(posedge clk_in or negedge rst_n)
  begin 
    if(rst_n == 1'b0) begin
        cycle_count <= 32'b0;
    end
    else begin
        cycle_count <= cycle_count + 1'b1;
    end
  end

  always
  begin 
     #18.518 clk <= ~clk;
  end

  soc zensoc
  (
    .clk(clk_in),
    .reset_button_n(rst_n),
    .uart_rx(),
    .uart_tx(),
    .leds()
  );

endmodule