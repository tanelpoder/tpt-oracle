#!/bin/ksh

# Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
#--------------------------------------------------------------------------------
#--
#-- File name:   enq_trace.sh
#-- Purpose:     Trace specific enqueue lock gets and process activity during 
#--              lock holding to find out why exactly was a lock taken and why
#--              hasn't it been released fast enough. This script should be used
#--              only when conventional troubleshooting mechanisms 
#--              (v$ views, ASH, hanganalyze, systemstate dumps) do not give
#--              enough relevant details about the hang 
#--
#-- Author:      Tanel Poder
#-- Copyright:   (c) http://www.tanelpoder.com 
#--              
#-- Other:       EXPERIMENTAL! This script needs reviewinng and adjustment,
#--              case by case. It's meant for diagnosing very specific hangs
#--              and you need to know what you're doing before running it in
#--              production
#--
#--------------------------------------------------------------------------------


# Set the lock type# we want to trace (should be 22 for CF enqueue on 11.1.0.7 and 18 on 10.2.0.3)
LOCK_TYPE=18

# --------------------------------------------------------------- 
# -- You can verify what's the correct lock type# for CF enqueue 
# -- using this query (run as SYS). Set the LOCK_TYPE variable 
# -- above to match the result of the query
# --------------------------------------------------------------- 
# select
#         i
# from
#    (
#             select
#                 rest.indx i,
#                 rest.resname type
#             from X$KSIRESTYP rest, X$KSQEQTYP eqt
#             where (rest.inst_id = eqt.inst_id)
#             and   (rest.indx = eqt.indx)
#             and   (rest.indx > 0)
# )
# where
#    type = 'CF'
# /
# --------------------------------------------------------------- 

PID=$1
echo Tracing PID $PID `ps -ocomm -p $PID | grep -v COMMAND`

dtrace $LOCK_TYPE -p $PID -qn '
/* ring buffer policy probably not needed due low trace volume so its commented out
  #pragma D option bufpolicy=ring
  #pragma D option bufsize=256k
*/

pid$target:oracle:ksqgtlctx:entry
/arg4 == $1/
{
    gettime=timestamp; 
    enqHolder  = pid;
    enqAddress = arg0;
    printf("%d [%Y]   getting enqueue: pid=%d proc=%s enqAddress=0x%x locktype#=%d get_stack={", gettime, walltimestamp, pid, curpsinfo->pr_psargs, enqAddress, arg4);
    ustack(50);
    printf("}\n");
}

pid$target:oracle:ksqrcl:entry
/arg0 == enqAddress/ {
    printf("%d [%Y] releasing enqueue: pid=%d proc=%s enqAddress=0x%x usec_held=%d\n", timestamp, walltimestamp, pid, curpsinfo->pr_psargs, arg0, (timestamp-gettime)/1000);
    enqAddress = 0;
}

pid$target:oracle:kslwtb_tm:entry 
/enqAddress && enqHolder == pid/ {
    currentWait = arg0;
}

pid$target:oracle:kslwte_tm:return
/enqAddress && enqHolder == pid/ {
    currentWait = 0;
}

tick-1sec
/enqAddress/
{
    printf("%d [%Y] still holding enqueue: pid=%d proc=%s enqAddress=0x%x current_wait=%d current_stack={", timestamp, walltimestamp, pid, curpsinfo->pr_psargs, enqAddress, currentWait);
    stack(50);
    ustack(50);
    printf("}\n");
}
'

