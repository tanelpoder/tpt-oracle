#!/bin/bash

#
# Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
# Name:       qer_trace.sh - Query Execution Row-source Trace script
# Version:    0.2 
# Author:     Tanel Poder (http://blog.tanelpoder.com)
#
# Notes:      Comment out the kcbgtcr:entry and kcbgtcr:return functions if you
#             want to reduce the amount of output this script generates or see the
#             output being indented more and more to the right without returning
#             (dtrace doesn't recognize the return call in some cases)

dtrace -Fp $1 -n '

pid$target:oracle:opifch*:entry 
{}

pid$target:oracle:opifch*:return
{ printf("= %x", arg1) }

struct qer_rws {
    uint16_t rws_id;
    uint16_t rws_parent;
};

struct qer_rws op;

pid$target:oracle:qer*Fetch*:entry
/*, pid$target:oracle:kpofcr:entry
  , pid$target:oracle:rwsfcd:entry */
{
    op.rws_parent = *(uint32_t *)copyin(arg0,2);
    op.rws_id = *(uint32_t *)copyin(arg0+2,2);
    printf("op=%d par=%d rows=%d", op.rws_id, op.rws_parent, arg4)

}

pid$target:oracle:qer*Fetch*:return
/*, pid$target:oracle:kpofcr:return
  , pid$target:oracle:rwsfcd:return */
{ printf("= %d", arg1) }


struct kcb_dba_t {
    uint32_t ts;
    uint16_t rfile;
    uint32_t block;
};

struct kcb_dba_t dba;

pid$target:oracle:kcbgtcr:entry
{ 

    dba.ts     = *(uint32_t *) copyin(arg0,4);
    dba.rfile  = *(uint32_t *) copyin(arg0+4,4) >> 22 & 0x000003FF ; 
    dba.block  = *(uint32_t *) copyin(arg0+4,4) & 0x003FFFFF ;
    
    printf("ts=%d rfile=%x block=%d %x x$kcbwh.indx=%x", dba.ts, dba.rfile, dba.block, arg1,arg2); 

} 

pid$target:oracle:kcbgtcr:return
{ printf("= %x %x", arg0, arg1) }

'
