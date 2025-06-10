`timescale 1ns/1ps
module pynq(
    input wire        board_clk,
    input wire        reset_button_n,
    input wire        uart_rx,
    output wire       uart_tx,
    output wire [3:0] leds
);

  wire rst;
  assign rst = ~reset_button_n;
  PLL sys_clk_gen
  (
    .resetn      (1'b1),
    .CLK_I_125M   (board_clk),
    .CLK_O_27M   (clk_27M   ), // 16 MHz, this clock we set to 16MHz
    .locked      (pll_locked)
  );

    // 1) 先声明一个中间网线
  wire gated_clk;

  // 2) 用 assign 给它接上门控
  assign gated_clk = clk_27M & rst;

  soc zensoc
  (
    .clk(gated_clk),
    .reset_button_n(rst),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
    .leds(leds)
  );
endmodule