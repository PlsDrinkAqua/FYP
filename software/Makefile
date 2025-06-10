# Just run "make" to create ../src/mem_init.v

CFLAGS = -mno-save-restore -march=rv32im2p0 -mabi=ilp32 -nostartfiles -nostdlib -static -O1
# Let CC tell us where its libgcc.a lives
CC = riscv64-unknown-elf-gcc
LIBS := $(shell $(CC) -print-libgcc-file-name)
OUTDIR = /mnt/d/FYP_workplace/picorv32/rtl/ram


OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump

all: mem_init.v prog.hex conv_to_init

conv_to_init: conv_to_init.c
	gcc -DDEPTH=8192 -o conv_to_init conv_to_init.c

mem_init.v: prog.bin conv_to_init
	rm -f $(OUTDIR)/mem_init.v
	./conv_to_init prog.bin > $(OUTDIR)/mem_init.v
	cp $(OUTDIR)/mem_init.v ./hex/

# main.o: main.c
# 	$(CC) $(CFLAGS) -c main.c
main.o: rdx2fft.c
	$(CC) $(CFLAGS) -c rdx2fft.c -o $@
# main.o: fft.c
# 	$(CC) $(CFLAGS) -c fft.c -o $@

# main.o: mul_test.c
# 	$(CC) $(CFLAGS) -c mul_test.c -o $@

# countdown_timer.o: countdown_timer.c
# 	$(CC) $(CFLAGS) -c countdown_timer.c

tools.o: tools.c
	$(CC) $(CFLAGS) -c tools.c

uart.o: uart.c
	$(CC) $(CFLAGS) -c uart.c

leds.o: leds.c
	$(CC) $(CFLAGS) -c leds.c

prog.elf: boots.s main.o uart.o leds.o tools.o
	$(CC) $(CFLAGS) -Tlink.ld -o prog.elf boots.s main.o \
          uart.o leds.o tools.o -lgcc

prog.bin: prog.elf
	$(OBJCOPY) prog.elf -O binary prog.bin
#	$(OBJCOPY) -j .text prog -O binary prog.bin

prog.hex: prog.bin
	od -v -Ax -t x4 prog.bin > prog.hex

clean:
	rm -f prog.elf prog.hex prog.bin main.o conv_to_init uart.o leds.o tools.o



# “make disasm” 会生成 prog.dis，里面就是完整的机器码 + 汇编
disasm: prog.elf
	@echo "=> Disassembling prog.elf into prog.dis …"
	$(OBJDUMP) -d prog.elf > prog.dis
	@echo "=> done. See prog.dis"
