#!/usr/bin/env python3

# Copyright 2022 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

from __future__ import print_function
import sys, os

stringlist = []

# parse stacks
for l in sys.stdin:
    l = l.rstrip().split('<-')
    l.reverse()
    
    x = []
    for f in l:
        x.append(f.split('+')[0])

    s = ""
    for f in x:
        s += "%s->" % f

    stringlist.append(s) 

prefixlength = len(os.path.commonprefix(stringlist)) - 2
s = os.path.commonprefix(stringlist).split("->")

# report
if sys.argv[1] == "prefix":
    for (i,f) in enumerate(s):
        print("#%3d %s %s" % (len(s)-i, " "*i, f))
else:
    for s in stringlist:
        print(" ", s[prefixlength:-2])

