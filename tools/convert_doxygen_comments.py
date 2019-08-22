#!/usr/bin/env python
import sys
import os
import argparse

parser = argparse.ArgumentParser(description="Convert comments in Pintos source to Doxygen-friendly comments.")

parser.add_argument("--in_place", action='store_true', default=False, help="convert the comments in place")
parser.add_argument("input", help="Input file or directory for the sources")

SOURCE_SUFFIX = (".c", ".h", ".cc")

def find_sources(rootDir):
    sources = []
    for directory, subdirs, fileList in os.walk(rootDir):
        for fname in fileList:
            if fname.endswith(SOURCE_SUFFIX):
                full_path = os.path.join(directory, fname)
                sources.append(full_path)
    return sources

def convert_comment(fname, in_place):
    source_f = open(fname, "r") 
    if in_place:
        bak_fname = fname + ".bak"
        bak_f = open(bak_fname, "w")
    modified = False
    for line in source_f:
        idx = line.find("/*")
        if idx == 0:
            line = "/**" + line[2:]
            modified = True
        elif idx > 0:
            prefix = line[:idx].strip()
            if prefix:
                # only if it's potentially a comment for a field
                line = line[:idx] + "/**<" + line[idx + 2:]
            modified = True
        if in_place:
            bak_f.write(line)
        else:
            sys.stdout.write(line)
    source_f.close()
    if in_place:
        bak_f.close()
        if modified:
            os.rename(bak_fname, fname)
            print "converted comments in " + fname
        else:
            os.remove(bak_fname)

if __name__ == "__main__":
    args = parser.parse_args()
    if os.path.isfile(args.input):
        convert_comment(args.input, args.in_place)
    elif os.path.isdir(args.input):
        sources = find_sources(args.input)
        for source in sources:
            convert_comment(source, args.in_place)
