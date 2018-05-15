#!/bin/ksh

# Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
dtrace -F -q -p $1 -n '
    pid$target::kghalf:entry,pid$target::kghalp:entry { 
        from_heap=arg1; comment_ptr=arg5; 
        printf("(%s(%x), \"%s\")\n", copyinstr(from_heap+76),from_heap,copyinstr(comment_ptr)); 
    } 
    pid$target::kghalo:entry {
        from_heap=arg1; comment_ptr=arg8;
        printf("(%s(%x), \"%s\")\n", copyinstr(from_heap+76),from_heap,copyinstr(comment_ptr));
    }


    pid$target::kghalf:return,pid$target::kghalp:return,pid$target::kghalo:return { 
        printf("= %x\n", arg1);
    }
'
