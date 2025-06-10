#============================================================================
#
#
#	Bing
#
#
#----------------------------------------------------------------------------



#=========================== Sys Clock & rstn ================================
## Clock Signal     50M
set_property -dict { PACKAGE_PIN H16    IOSTANDARD LVCMOS33 } [get_ports { board_clk }]; #K17
create_clock -add -name sys_clk_pin -period 8 -waveform {0 4} [get_ports {board_clk}];

## mcu Rst_n
set_property -dict { PACKAGE_PIN D19  IOSTANDARD LVCMOS33 } [get_ports { reset_button_n }]; #PL_KEY1   M20
#----------------------------------------------------------------------------




#=========================== Debug JTAG ======================================

# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets IOBUF_jtag_TCK/O]

# mcu_TCK
# mcu_TDO
# mcu_TMS
# rst
# mcu_TDI
# JTAG Debug Port
# set_property -dict { PACKAGE_PIN U5  IOSTANDARD LVCMOS33 } [get_ports { mcu_TCK }]; #V20
# set_property -dict { PACKAGE_PIN V6  IOSTANDARD LVCMOS33 } [get_ports { mcu_TDO }]; #U20
# set_property -dict { PACKAGE_PIN U7  IOSTANDARD LVCMOS33 } [get_ports { mcu_TMS }]; #T20
# set_property -dict { PACKAGE_PIN V5  IOSTANDARD LVCMOS33 } [get_ports { mcu_TDI }]; #P20


#------------------------ End of Debug JTAG ----------------------------------





#=============================== UART 0 ======================================

set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { uart_tx }]; #N20
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports { uart_rx }]; #N18

#---------------------------- End of UART 0 --------------------------------


#LED1       ---> T12
#LED2       ---> U12
#LED3       ---> V12
#LED4       ---> W13
#PL_KEY1    ---> M20
#PL_KEY2    ---> M19



# ## GPIOA
# #LEDs
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { leds[0] }]; # T12
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { leds[1] }]; # U12
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { leds[2] }]; # V12
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { leds[3] }]; # W13

# #KEY
# set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { gpioA_4 }]; # M19

# # 40P
# set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { gpioA_5 }]; # P18
# set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports { gpioA_6 }]; # P19
# set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { gpioA_7 }]; # R18


# ## OLED Display
# set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33 } [get_ports { gpioA_20 }]; #OLED_DC          Y14
# set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { gpioA_21 }]; #OLED_RES         V16
# set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { gpioA_22 }]; #OLED_CLK   D0    U18
# set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { gpioA_23 }]; #OLED_SDIN  D1    T17
# set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { gpioA_24 }]; #VBAT             R17
# set_property -dict { PACKAGE_PIN W20   IOSTANDARD LVCMOS33 } [get_ports { gpioA_25 }]; #VDD              W20