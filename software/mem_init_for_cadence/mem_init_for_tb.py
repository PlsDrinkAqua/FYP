#!/usr/bin/env python3
import re

def transform_line(line):
    """
    把 `force zensoc.memory.u_sram.\mem_array[idx] = VALUE;`
    转成  `force memory.u_sram.mem_array[idx] = VALUE;`
    其它行原样返回（去掉行尾多余空白）。
    """
    m = re.match(
        r"\s*force\s+zensoc\.memory\.u_sram\.\\?mem_array\[(\d+)\]\s*=\s*(32'h[0-9A-Fa-f]+);",
        line
    )
    if m:
        idx, val = m.groups()
        return f"force memory.u_sram.mem_array[{idx}] = {val};"
    else:
        # 不是这类行就原样输出（去掉右侧空白及换行）
        return line.rstrip()

def process_file(infile, outfile):
    with open(infile, 'r') as fin, open(outfile, 'w') as fout:
        for line in fin:
            fout.write(transform_line(line) + "\n")

def main():
    print("=== transform.py ===")
    infile = "/home/oliver/picorv32_software/hex/force.v"
    outfile = "/home/oliver/picorv32_software/hex/for_cadence.v"
    try:
        process_file(infile, outfile)
    except FileNotFoundError:
        print(f"错误：找不到文件 '{infile}'")
    else:
        print(f"转换完成，结果已写入 '{outfile}'")

if __name__ == "__main__":
    main()
