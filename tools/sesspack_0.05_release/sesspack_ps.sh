#!/bin/sh

# Note that this is currently only for Solaris

while true
do
        echo `date +%Y%m%d%H%M%S`";"BEGIN_PS_SAMPLE > /tmp/sawr_ps_pipe
        ps -u oracle -o pid,time | awk '{ if ( NR > 1 ) print $1";"$2 }' > /tmp/sawr_ps_pipe
done

