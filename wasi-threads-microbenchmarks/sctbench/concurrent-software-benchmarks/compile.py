#! /usr/bin/env python

import os
import sys
import subprocess
from os import path
import errno

files = [f for f in os.listdir("src") if f.endswith(".c")]

files.sort()

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise

for file in files:
    basename = file[:-2]
    dir = "build"
    mkdir_p(dir)

    file = path.join("src", file)

    ofile = path.join(dir, basename + ".x")
    cmd = ["gcc", "-o", ofile, file, "-pthread", "-g", "-O0"]
    print (" ".join(cmd))
    subprocess.check_call(cmd)


    ofile = path.join(dir, basename + ".musl")
    cmd = ["/opt/x86_64-linux-musl-cross/bin/x86_64-linux-musl-gcc", "-o", ofile, file, "-pthread", "-g", "-O0"]
    print (" ".join(cmd))
    subprocess.check_call(cmd)


    ofile = path.join(dir, basename + ".wasm")
    cmd = ["/opt/wasi-sdk/bin/clang", "--target=wasm32-wasi-threads", "-Wl,--import-memory,--export-memory,--max-memory=3221225472", "-DWASM", "-o", ofile, file, "-pthread", "-g", "-O0"]
    print (" ".join(cmd))
    try:
        subprocess.check_call(cmd)
    except:
        print ("\033[91mFailed to compile", basename, "\033[0m")
        pass



