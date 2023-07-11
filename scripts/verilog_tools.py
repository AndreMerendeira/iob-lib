#!/usr/bin/env python3
import os
import iob_colors
import re


# Find include statements inside a list of lines and replace them by the contents of the included file and return the new list of lines
def replace_includes_in_lines(lines, VSnippetFiles):
    for line in lines:
        if re.search(r'`include ".*\.vs"', line):
            # retrieve the name of the file to be included
            tail = line.split('"')[1]
            found_vs = False
            for VSnippetFile in VSnippetFiles:
                if tail in VSnippetFile:
                    found_vs = True
                    # open the file to be included
                    with open(f"{VSnippetFile}", "r") as include:
                        include_lines = include.readlines()
                    # replace the include statement with the content of the file
                    # if the file to be included is *_portmap.vs or *_port.vs and has a ");" in the next line, remove the last comma
                    if re.search(r'`include ".*_portmap\.vs"', line) or re.search(
                        r'`include ".*_port\.vs"', line
                    ):
                        if re.search(r"\s*\);\s*", lines[lines.index(line) + 1]):
                            # find and remove the first comma in the last line of the include_lines ignoring white spaces
                            include_lines[-1] = re.sub(
                                r"\s*,\s*", "", include_lines[-1], count=1
                            )
                    # if the include_lines has an include statement, recursively replace the include statements
                    for include_line in include_lines:
                        if re.search(r'`include ".*\.vs"', include_line):
                            include_lines = replace_includes_in_lines(
                                include_lines, VSnippetFiles
                            )
                    # replace the include statement with the content of the file
                    lines[lines.index(line)] = "".join(include_lines)
            # if the file to be included is not found in the VSnippetFiles, raise an error
            if not found_vs:
                raise FileNotFoundError(
                    f"{iob_colors.FAIL}File {tail} not found! {iob_colors.ENDC}"
                )
    return lines


# Function to search recursively for every verilog file inside the search_path
def replace_includes(setup_dir="", build_dir=""):
    VSnippetFiles = []
    VerilogFiles = []
    SearchPaths = f"{build_dir}/hardware"
    VSnippetDir = f"{setup_dir}/hardware/aux"

    os.makedirs(VSnippetDir, exist_ok=True)

    for root, dirs, files in os.walk(SearchPaths):
        for file in files:
            if file.endswith(".vs"):
                VSnippetFiles.append(f"{root}/{file}")
                VerilogFiles.append(f"{root}/{file}")
            elif file.endswith(".v") or file.endswith(".sv") or file.endswith(".vh"):
                VerilogFiles.append(f"{root}/{file}")

    for VerilogFile in VerilogFiles:
        with open(VerilogFile, "r") as source:
            lines = source.readlines()
            # replace the include statements with the content of the file
            new_lines = replace_includes_in_lines(lines, VSnippetFiles)
        # write the new file
        with open(VerilogFile, "w") as source:
            source.writelines(new_lines)

    # Remove the VSnippetFiles
    for VSnippetFile in VSnippetFiles:
        os.remove(VSnippetFile)

    print(
        f"{iob_colors.INFO}Replaced Verilog Snippet includes with respective content and deleted the files.{iob_colors.ENDC}"
    )
