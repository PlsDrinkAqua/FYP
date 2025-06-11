#!/usr/bin/env python3
import re

def transform_line(line):

    m = re.match(
        r"\s*force\s+zensoc\.memory\.u_sram\.\\?mem_array\[(\d+)\]\s*=\s*(32'h[0-9A-Fa-f]+);",
        line
    )
    if m:
        idx, val = m.groups()
        return f"force memory.u_sram.mem_array[{idx}] = {val};"
    else:

        return line.rstrip()

def process_file(infile, outfile):
    with open(infile, 'r') as fin, open(outfile, 'w') as fout:
        for line in fin:
            fout.write(transform_line(line) + "\n")

def main():
    print("=== transform.py ===")
    infile = "./force.v"
    outfile = "./mem_init.v"
    try:
        process_file(infile, outfile)
    except FileNotFoundError:
        print(f"Error：cannot find the file '{infile}'")
    else:
        print(f"Successful '{outfile}'")

if __name__ == "__main__":
    main()
