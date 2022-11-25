#!/usr/bin/env python3

# Copyright 2022 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

from __future__ import print_function
import sys, os

full_stringlist = []

# parse stacks
for l in sys.stdin:
    l = l.rstrip().split('<-')
    l.reverse()
    
    x = []
    for f in l:
        if f.startswith("__sighandler()"):
            break
        else:
            x.append(f.split('+')[0])

    s = ""
    for f in x:
        s += "%s/" % f

    full_stringlist.append(s) 

prefixlength = len(os.path.commonpath(full_stringlist))
common_funclist = os.path.commonpath(full_stringlist).split("/")

# report
if sys.argv[1] == "prefix":
    for (i,f) in enumerate(common_funclist):
        print("#%3d %s %s" % (len(common_funclist)-i, " "*i, f))
else:
    for suffix_funcs in full_stringlist:
        print(" ", suffix_funcs[prefixlength:-1].replace('/','->'))

