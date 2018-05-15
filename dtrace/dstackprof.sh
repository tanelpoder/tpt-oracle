#!/bin/ksh
#
# Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
#################################################################################
#
# File name:   dstackprof.sh         v1.02 29-Aug-2008
# Purpose:     Samples target process stack using DTrace, strips the PC function 
#              offsets from output and re-aggregates 
#
# Author:      Tanel Poder
# Copyright:   (c) http://www.tanelpoder.com
#
# Usage:       dstackprof.sh <PID> [SECONDS] [STACKS] [FRAMES]
# 	        
#	        
# Other:       
#              
#              
#
#################################################################################

DEFAULT_SECONDS=5
DEFAULT_FRAMES=100
DEFAULT_STACKS=20

FREQUENCY=1001

[ $# -lt 1 ] && echo "  Usage: $0 <PID> [SECONDS] [STACKS] [FRAMES]\n" && exit 1
[ -z $2 ] && SECONDS=$DEFAULT_SECONDS || SECONDS=$2
[ -z $3 ] && STACKS=$DEFAULT_STACKS || STACKS=$3
[ -z $4 ] && FRAMES=$DEFAULT_FRAMES || FRAMES=$4
PROCESS=$1

echo
echo "DStackProf v1.02 by Tanel Poder ( http://www.tanelpoder.com )"
echo "Sampling pid $PROCESS for $SECONDS seconds with stack depth of $FRAMES frames..."
echo

dtrace -q -p $PROCESS -n '
profile-'$FREQUENCY'
/pid == $target/ { 
    @u[ustack('$FRAMES')] = count();
    @k[stack('$FRAMES')]  = count();
} 
tick-1sec
/i++ >= '$SECONDS'/ {
    exit(0);
}
END { 
    printa(@u);
    printa(@k);
}
' |     sed 's/^ *//;/^$/d;s/+.*$//;s/^oracle`//g' | \
        awk '/^$/{ printf "\n" }/^[0-9]*$/{ printf ";%s\n", $1 }/[a-z]/{ printf "%s<", $1 }END{ printf "\n" }' | \
        sed '/^;/d' | \
        sort | \
	awk -F";" '
            /NR==1/{ sum=0; total=0; oldstack=$1 }
            { 
              if (oldstack==$1) {sum+=$2;total+=$2} 
              else {printf "%d samples with stack below<__________________<%s\n", sum, oldstack; oldstack=$1; sum=$2; total+=$2} 
            }
            END {printf "%d samples with stack below<__________________<%s\n%d Total samples captured\n", sum, oldstack, total}
        ' | \
        sort -bn | \
        tail -$((STACKS+1)) | \
        tr '<' '\n'

