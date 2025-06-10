#!/usr/bin/env python3
import re

def generate_forces(input_path, output_path=None):
    """
    从 input_path 中提取所有 mem_array[...] = 32'h...; 的行，
    生成对应的 force zensoc.memory.u_sram.\mem_array[...] = 32'h...;
    如果给出了 output_path，就写入文件，否则打印到 stdout。
    """
    pattern = re.compile(r"mem_array\[(\d+)\]\s*=\s*(32'h[0-9a-fA-F]+);")
    lines_out = []
    with open(input_path, 'r') as fin:
        for line in fin:
            m = pattern.search(line)
            if m:
                idx, val = m.groups()
                # 注意反斜杠后要有空格，才能正确识别转义标识符
                force_line = f"force zensoc.memory.u_sram.\\mem_array[{idx}] = {val};"
                lines_out.append(force_line)
    if output_path:
        with open(output_path, 'w') as fout:
            for l in lines_out:
                fout.write(l + "\n")
        print(f"已将 {len(lines_out)} 条 force 语句写入：{output_path}")
    else:
        for l in lines_out:
            print(l)

def main():
    print("=== generate_forces.py ===")
    inp = "/home/oliver/picorv32_software/hex/mem_init.v"
    out = "/home/oliver/picorv32_software/hex/force.v"
    if out == '':
        out = None

    try:
        generate_forces(inp, out)
    except FileNotFoundError:
        print(f"错误：找不到文件 '{inp}'")
    except Exception as e:
        print("处理时发生错误：", e)

if __name__ == '__main__':
    main()
