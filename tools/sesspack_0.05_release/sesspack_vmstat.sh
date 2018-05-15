#!/bin/sh

# Note that this is currently only for Solaris

while true
do 
	echo `date +%Y%m%d%H%M%S`";"BEGIN_SAMPLE > /tmp/sawr_vmstat_pipe
	vmstat -s | awk '{ print $1";"$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9 }' > /tmp/sawr_vmstat_pipe
done

