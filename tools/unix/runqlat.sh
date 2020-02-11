#!/bin/bash

# Tiny Linux /proc/<pid>/schedstat demo script by Tanel Poder
#   https://tanelpoder.com

PID=$1
SLEEP=1

echo Sampling /proc/$PID/schedstat every $SLEEP seconds...

while true ; do
    read -r CPU_NS_1 LAT_NS_1 SLICES_ON_THIS_CPU_1 < /proc/$PID/schedstat
    sleep $SLEEP
    read -r CPU_NS_2 LAT_NS_2 SLICES_ON_THIS_CPU_2 < /proc/$PID/schedstat
    printf "%10d %10d" $((($CPU_NS_2-$CPU_NS_1)/10000000)) $((($LAT_NS_2-$LAT_NS_1)/10000000))
    echo
done

