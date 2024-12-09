#!/bin/bash
# A little helper script for finding ORACLE_HOMEs for all running instances in a Linux server
# by Tanel Poder (http://blog.tanelpoder.com)

printf "%6s %-20s %-80s\n" "PID" "NAME" "ORACLE_HOME"
ps -Ao pid,cmd | grep _pmon_ | grep -v grep | while read pid pname; do
	printf "%6s %-20s %-80s\n" $pid $pname `readlink /proc/$pid/exe | sed 's/bin\/oracle$//'`
done
