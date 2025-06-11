#!/usr/bin/env python3
import re

def generate_forces(input_path, output_path=None):

    pattern = re.compile(r"mem_array\[(\d+)\]\s*=\s*(32'h[0-9a-fA-F]+);")
    lines_out = []
    with open(input_path, 'r') as fin:
        for line in fin:
            m = pattern.search(line)
            if m:
                idx, val = m.groups()

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
    inp = "../=mem_init.v"
    out = "./force.v"
    if out == '':
        out = None

    try:
        generate_forces(inp, out)
    except FileNotFoundError:
        print(f"Error：cannot find file '{inp}'")
    except Exception as e:
        print("error：", e)

if __name__ == '__main__':
    main()
