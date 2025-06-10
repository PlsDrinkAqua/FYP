#include "my_stdint.h"
#include "tools.h"

// 读取 64-bit cycle（rdcycleh/rdcycle/rdcycleh）  
uint64_t read_cycle64(void) {
    uint32_t hi, lo, hi2;
    do {
        asm volatile ("rdcycleh %0" : "=r"(hi));
        asm volatile ("rdcycle  %0" : "=r"(lo));
        asm volatile ("rdcycleh %0" : "=r"(hi2));
    } while (hi != hi2);
    return ((uint64_t)hi << 32) | lo;
}
