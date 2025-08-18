#!/usr/bin/env python3

"""
Replace macros/placeholders inside a file with their corresponding value.
"""

import re
import sys


def macros_inplace_change(filepath, macros_file):
    with open(filepath) as f:
        s = f.read()

    with open(macros_file) as f:
        macro_lines = f.readlines()

    for macro_line in macro_lines:
        macro_name, macro_value = macro_line.split()
        s = s.replace(f"/*{macro_name}_MACRO*/", macro_value)

    s = sum_inplace(s)

    with open(filepath, "w") as f:
        f.write(s)


def sum_inplace(s):
    # find pattern /*ADDR+OFFSET*/, evaluate as hex values and replace inplace
    # with result
    pattern = re.compile(r"\/\*(?P<addr>\w+)\+(?P<offset>\w+)\*\/")
    matches = pattern.findall(s)
    for match in matches:
        match_string = f"/*{match[0]}+{match[1]}*/"
        sum = hex(int(match[0], 16) + int(match[1], 16))
        sum = sum.replace("0x", "")  # remove 0x prefix
        s = s.replace(match_string, sum)
    return s


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: {} <filepath> <macros filepath>".format(sys.argv[0]))
        sys.exit(1)
    macros_inplace_change(sys.argv[1], sys.argv[2])
