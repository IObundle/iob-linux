#!/usr/bin/env python3

import sys

def macros_inplace_change(filepath, macros_file):
    with open(filepath) as f:
        s = f.read()

    with open(macros_file) as f:
        macro_lines = f.readlines()

    for macro_line in macro_lines:
        macro_name, macro_value = macro_line.split()
        s = s.replace(f"/*{macro_name}_MACRO*/", macro_value)

    with open(filepath, "w") as f:
        f.write(s)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: {} <filepath> <macros filepath>".format(sys.argv[0]))
        sys.exit(1)
    macros_inplace_change(sys.argv[1], sys.argv[2])
