/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause.
*/

#include "uart.h"
#include "my_stdint.h"

#define INT32_MIN (int32_t)0x80000000

#define UART_DIV ((volatile unsigned char *) 0x80000008)
#define UART_DATA ((volatile unsigned char *) 0x8000000c)

void uart_set_div(unsigned int div)
{
  volatile int delay;

  *UART_DIV = div;

  /* Need to delay a little */
  for (delay = 0; delay < 200; delay++) {}
}

void uart_print_hex(unsigned int val)
{
  char ch;
  int i;

  for (i = 0; i < 8; i++) {
    ch = (val & 0xf0000000) >> 28;
    *UART_DATA = "0123456789abcdef"[ch];
    val = val << 4;
  }
}

char uart_getchar(void)
{
  unsigned char ch;

  /* UART gives 0xff when empty */
  while ((ch = *UART_DATA) == 0xff) {}

  return(ch);
}

void uart_putchar(char ch)
{
  *UART_DATA = ch;
}
  
void uart_puts(char *s)
{
  while (*s != 0) *UART_DATA = *s++;
}

/* 无符号整数，高→低顺序打印 */
void uart_print_uint(uint32_t val) {
  if (val == 0) {
      uart_putchar('0');
      return;
  }
  uint32_t power = 1;
  while (val / power >= 10) {
      power *= 10;
  }
  while (power > 0) {
      uint8_t d = val / power;
      uart_putchar('0' + d);
      val %= power;
      power /= 10;
  }
}

/* 带符号整数 */
void uart_print_int(int32_t v) {
  if (v < 0) {
      uart_putchar('-');
      /* 处理最小值 */
      if (v == INT32_MIN) {
          /* “2147483648” */
          uart_print_uint((uint32_t)2147483648u);
          return;
      }
      v = -v;
  }
  uart_print_uint((uint32_t)v);
}

/* 浮点数，precision 表示小数点后位数 */
void uart_print_float(float val, uint8_t precision) {
  /* 处理负号 */
  if (val < 0.0f) {
      uart_putchar('-');
      val = -val;
  }

  /* 整数部分 */
  uint32_t int_part = (uint32_t)val;
  uart_print_uint(int_part);

  /* 小数部分 */
  if (precision > 0) {
      uart_putchar('.');
      float frac = val - (float)int_part;
      /* 连续提取每一位小数 */
      while (precision--) {
          frac *= 10.0f;
          uint8_t digit = (uint8_t)frac;    /* 0..9 */
          uart_putchar('0' + digit);
          frac -= digit;
      }
  }
}

/*==================================================================*/
/*                      NEW: INPUT ROUTINES                         */
/*==================================================================*/

/* Block until we see one of [0-9], '-' or '.'. */
static char uart_peek_numchar(void)
{
    char c;
    do {
        c = uart_getchar();
    } while (!((c >= '0' && c <= '9') || c == '-' || c == '.'));
    return c;
}

/**
 * uart_read_int
 *   Reads an optional sign and decimal digits, returns as int32_t.
 */
int32_t uart_read_int(void)
{
    char c = uart_peek_numchar();
    int32_t sign = 1;
    int32_t result = 0;

    if (c == '-') {
        sign = -1;
        c = uart_getchar();  /* consume '-' */
    }

    /* read digits */
    while (c >= '0' && c <= '9') {
        result = result * 10 + (c - '0');
        c = uart_getchar();
    }

    return sign * result;
}

/**
 * uart_read_double
 *   Reads an optional sign, integer part, optional '.', fractional part.
 *   Returns as double.
 */
double uart_read_double(void)
{
    char c = uart_peek_numchar();
    int sign = 1;
    double result = 0.0;

    if (c == '-') {
        sign = -1;
        c = uart_getchar();  /* consume '-' */
    }

    /* integer part */
    while (c >= '0' && c <= '9') {
        result = result * 10.0 + (c - '0');
        c = uart_getchar();
    }

    /* fractional part */
    if (c == '.') {
        double place = 0.1;
        c = uart_getchar();
        while (c >= '0' && c <= '9') {
            result += (c - '0') * place;
            place *= 0.1;
            c = uart_getchar();
        }
    }

    return sign * result;
}
