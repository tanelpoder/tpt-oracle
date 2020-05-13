#!/bin/bash

# Tiny Linux /proc/<pid>/schedstat demo script by Tanel Poder
#   https://tanelpoder.com
#
# You may want to run this with high priority:
#   sudo nice -n -10 ./runqlat.sh PID
#
# currently this script assumes that it will speep exactly for $SLEEP 
# seconds, but it can itself be affected by CPU overload and you may 
# see values that don't add up to 1000 ms per sec 
# (or negative percentages in the derived BLKD% column)

PID=$1
SLEEP=1

echo Sampling /proc/$PID/schedstat every $SLEEP seconds...

printf "%6s %6s %6s\n" "CPU%" "RUNQ%" "SLP%"
while true ; do
    read -r CPU_NS_1 LAT_NS_1 SLICES_ON_THIS_CPU_1 < /proc/$PID/schedstat
    sleep $SLEEP
    read -r CPU_NS_2 LAT_NS_2 SLICES_ON_THIS_CPU_2 < /proc/$PID/schedstat

    ON_CPU=$((($CPU_NS_2-$CPU_NS_1)/10000000)) 
    ON_RUNQ=$((($LAT_NS_2-$LAT_NS_1)/10000000)) 
    OTHER=$((100-($ON_CPU+ON_RUNQ)))

    printf "%6d %6d %6d" $ON_CPU $ON_RUNQ $OTHER
    echo
done

