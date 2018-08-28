#!/bin/bash

# Tiny Linux /proc/<pid>/io demo script by Tanel Poder
#   http://www.tanelpoder.com

PID=$1
TMPFILE1=/tmp/procio.${PID}.tmp1
TMPFILE2=/tmp/procio.${PID}.tmp2
SLEEP=5

trap 'rm -f $TMPFILE1 $TMPFILE2 ; exit 0' 0

echo Sampling process $PID IO every $SLEEP seconds...

cat /proc/$PID/io > $TMPFILE2

while true ; do
    mv $TMPFILE2 $TMPFILE1
    sleep $SLEEP
    cat /proc/$PID/io > $TMPFILE2
    paste $TMPFILE1 $TMPFILE2 | awk '{ printf "%30s %d\n", $1, $4-$2 }'
    echo
done

