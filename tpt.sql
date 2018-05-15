-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set define off

def _cmds_0=""
def _cmds_1="s &sid"
def _cmds_2="snapper all 5 1 &sid"
def _cmds_3="waitprof print &sid e123 100000"
def _cmds_4="latchprof sid,name &sid % 100000"
def _cmds_5="latchprofx sid,name,hmode,func &sid % 100000"
def _cmds_6="mutexprof id,loc,req,blk 1=1" 
def _cmds_7="bufprof &sid 1000"
def _cmds_8="sample indx,ksllalaq x$ksupr ksllalaq!=hextoraw(''00'') 10000"
def _cmds_9="ostackprof &sid 0 100"

set define on

prompt   ========================================================= 
prompt   =                                                       =
prompt   =         Tanel Poder's Troubleshooting scripts         =
prompt   =        (c) 2004-2018 http://www.tanelpoder.com        =
prompt   =                                                       =
prompt   =================== TPT Script usage ====================
prompt
prompt   0) Exit menu
prompt
prompt   1) @&_cmds_1
prompt
prompt   2) @&_cmds_2
prompt
prompt   3) @&_cmds_3
prompt
prompt   4) @&_cmds_4 
prompt
prompt   5) @&_cmds_5
prompt
prompt   6) @&_cmds_6 
prompt
prompt   7) @&_cmds_7
prompt
prompt   8) @&_cmds_8
prompt
prompt   9) @&_cmds_9
prompt
prompt
prompt

accept _input char default 0 prompt "Enter command number [0]: "
prompt


def _cmds_0=""
def _cmds_1="s &&sid"
def _cmds_2="snapper out 6 1 &sid"
def _cmds_3="waitprof print &sid e123 100000"
def _cmds_4="latchprof sid,name &sid % 100000"
def _cmds_5="latchprofx sid,name,hmode,func &sid % 100000"
def _cmds_6="mutexprof id,loc,req,blk 1=1" 
def _cmds_7="bufprof"
def _cmds_8="sample indx,ksllalaq x$ksupr ksllalaq!=hextoraw(''00'') 10000"
def _cmds_9="ostackprof &sid 0 100"

col tpt_cmd new_value _tpt_cmd

set termout off
select
    case '&_input'
        when '1' then '&_cmds_1'
        when '2' then '&_cmds_2'
        when '3' then '&_cmds_3'
        when '4' then '&_cmds_4'
        when '5' then '&_cmds_5'
        when '6' then '&_cmds_6'
        when '7' then '&_cmds_7'
        when '8' then '&_cmds_8'
        when '9' then '&_cmds_9'
    else
        ''
    end tpt_cmd 
from
    dual
/
set termout on

--def _tpt_cmd

prompt SQL> @&_tpt_cmd 
@&_tpt_cmd

