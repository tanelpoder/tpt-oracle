#!/usr/bin/sh

################################################################################
# Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
#             
# Script:    procmm.sh (Process Memory Matrix) v1.03
#             
# Purpose:   Show process memory usage for different mappings and segment types
#
# Copyright: Copyright (c) 2010 Tanel Poder ( http://tech.e2sn.com )
#            All rights reserved.
#             
# ------------------------------------------------------------------------------
#             
# Usage:     procmm.sh [-t|-a] <pidlist> 
#
#            Without any special options procmm.sh will show you a matrix
#            of the processes address space segment types and their respective
#            memory usages/reservations, separately for every process in the 
#            pidlist.
#
#            -t option will only show total memory usage of all processes
#               listed in pidlist. Any ANON memory usage and swap reservation
#               for *shared* mappings (mapped binaries, libraries, shared memory
#               segments - Oracle SGA) is not shown.
#               Note that pmap command is not cheap one, so you probably do not
#               want to run it over many processes frequently
#
#            -a option will list ANON memory usage and swap reservation also for
#               shared mappings. The -t and -a options are mutually exclusive
#               as it doesn not make sense to sum together the same shared mapping
#               memory usage of multiple processes.
#             
# Comments:  This script currently only works on Solaris as the pmap command
#            on other platforms doesnt currently show all required info. On
#            Linux it will be possible to read this info from proc filesystem (TODO)
#            
#            If you are getting "address space is changing" errors from pmap then try 
#            again or suspend the process for duration of  this script run.
#            NB! Suspending processes may be dangerous in some cases (such as when 
#            it is holding a hot latch) so you better know what you are doing.
#
################################################################################

get_matrix() {
    p_pid="$1"
    #[ "$1" -eq 0 ] && p_pid="all" || p_pid=$1
    #pmap -x $p_pid | tr '[]' '  ' | egrep -v "^ *Address|^---------|total Kb|^[0-9]*:" | nawk ''
    join -j 1 /tmp/procmm-x.$$ /tmp/procmm-s.$$  > /tmp/blah 
    join -j 1 /tmp/procmm-x.$$ /tmp/procmm-s.$$ | sed 's/ism shmid/ism_shmid/g' | tr '[]' '  ' | egrep -v "^ *Address|^---------|total Kb|^[0-9]*:" | nawk '
    {
        item=$7
        #print "before", s
        sub(/.*\.so.*/, "lib", item)
        #print "after", s
        #item = gensub(/.*\.so.*/, "lib", "g", $7)
        #item = gensub(/lib.+|ld\..+/, "lib", "g", $7)
        #print $7 " = " item 
        vmem[item] += $2 
        rss[item]  += $3 
        anon[item] += $4
        locked[item] += $5
        swap[item] += $9
        #print $0
    } 
    END { 
        printf "%6-s %20s %12s %12s %12s %12s %12s\n", "PID", "SEGMENT_TYPE", "VIRTUAL", "RSS", "ANON", "LOCKED", "SWAP_RSVD"
        printf "------ -------------------- ------------ ------------ ------------ ------------ ------------\n"
        for (x in vmem) {
            printf "%6-d %20s %12d %12d %12d %12d %12d\n", '$p_pid', x, vmem[x], rss[x], anon[x], locked[x], swap[x]

            total_vmem += vmem[x]
            total_rss  += rss[x]
            total_anon += anon[x]
            total_locked += locked[x]
            total_swap += swap[x]
        }
        
        printf "------ -------------------- ------------ ------------ ------------ ------------ ------------\n"
        printf "%6-d %20s %12d %12d %12d %12d %12d\n\n", '$p_pid', "TOTAL(kB)", total_vmem, total_rss, total_anon, total_locked, total_swap

    }
    '
}

echo "\n-- procmm.sh: Process Memory Matrix v1.03 by Tanel Poder ( http://tech.e2sn.com )"

if [ $# -lt 1 ] ; then
    echo "\nUsage:\n"
    echo "     $0 [-a|-t] <pidlist>\n"
    echo "     Option -a would report swap reservations and anonymous memory"
    echo "     for shared mappings (like Oracle SGA) too\n"
    exit 1
fi

# defaults
pmap_option=""
compute_total=0

case "$1" in
    "-a") pmap_option="a" ; shift ;;
    "-t") compute_total=1 ; shift ;;
esac

echo "-- All numbers are shown in kilobytes\n" 

pidlist="$*"
#echo $pidlist

if [ $compute_total -eq 0 ]; then 
    for pid in $pidlist; do
        # ps -opid,vsz,rss,args -p $pid | nawk '/ *[0-9]+/{ printf "-- ps info: PID=%d VSZ=%d RSS=%d ARGS=%s\n\n", $1,$2,$3,$4 }'
        rm -f /tmp/procmm-x.$$ /tmp/procmm-s.$$
        pmap -x$pmap_option $pid | sed 's/ism shmid/ism_shmid/g' | tr '[]' '  ' | egrep -v "^ *Address|^---------|total Kb|^[0-9]+:"  > /tmp/procmm-x.$$ 
        pmap -S$pmap_option $pid | sed 's/ism shmid/ism_shmid/g' | tr '[]' '  ' | egrep -v "^ *Address|^---------|total Kb|^[0-9]+:"  > /tmp/procmm-s.$$ 
        get_matrix $pid
        rm -f /tmp/procmm-x.$$ /tmp/procmm-s.$$
    done
else
    rm -f /tmp/procmm-x.$$ /tmp/procmm-s.$$
    printf "Total PIDs %d, working: " $#
    for pid in $pidlist; do
        # ps -opid,vsz,rss,args -p $pid | nawk '/ *[0-9]+/{ printf "-- ps info: PID=%d VSZ=%d RSS=%d ARGS=%s\n\n", $1,$2,$3,$4 }'
        pmap -x$pmap_option $pid | sed 's/ism shmid/ism_shmid/g' | tr '[]' '  ' | egrep -v "^ *Address|^---------|total Kb|^[0-9]*:" >> /tmp/procmm-x.$$ 
        pmap -S$pmap_option $pid | sed 's/ism shmid/ism_shmid/g' | tr '[]' '  ' | egrep -v "^ *Address|^---------|total Kb|^[0-9]*:" >> /tmp/procmm-s.$$ 
        printf "."
   done
   printf "\n\n"
   get_matrix 0
   echo "-- Note that in Total (-t) calculation mode it makes sense to look into ANON and SWAP_RSVD"
   echo "-- totals only as other numbers may be heavily \"doublecounted\" due to overlaps of shared mappings\n"
   rm -f /tmp/procmm-x.$$ /tmp/procmm-s.$$
 fi
