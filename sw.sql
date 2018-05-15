-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   sw.sql
-- Purpose:     Display current Session Wait info
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @sw <sid>
--              @sw 52,110,225
--              @sw "select sid from v$session where username = 'XYZ'"
--              @sw &mysid
--
--------------------------------------------------------------------------------

col sw_event    head EVENT for a40 truncate
col sw_p1transl head P1TRANSL for a42
col sw_sid      head SID for 999999

col sw_p1       head P1 for a19 justify left word_wrap
col sw_p2       head P2 for a19 justify left word_wrap
col sw_p3       head P3 for a19 justify left word_wrap

select 
    sid sw_sid, 
    CASE WHEN state != 'WAITING' THEN 'WORKING'
         ELSE 'WAITING'
    END AS state, 
    CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
         ELSE event
    END AS sw_event, 
    seq#, 
    seconds_in_wait sec_in_wait, 
    CASE state WHEN 'WAITING' THEN NVL2(p1text,p1text||'= ',null)||CASE WHEN P1 < 536870912 THEN to_char(P1) ELSE '0x'||rawtohex(P1RAW) END ELSE null END SW_P1,
    CASE state WHEN 'WAITING' THEN NVL2(p2text,p2text||'= ',null)||CASE WHEN P2 < 536870912 THEN to_char(P2) ELSE '0x'||rawtohex(P2RAW) END ELSE null END SW_P2,
    CASE state WHEN 'WAITING' THEN NVL2(p3text,p3text||'= ',null)||CASE WHEN P3 < 536870912 THEN to_char(P3) ELSE '0x'||rawtohex(P3RAW) END ELSE null END SW_P3,
    CASE state WHEN 'WAITING' THEN 
        CASE 
            WHEN event like 'cursor:%' THEN
                '0x'||trim(to_char(p1, 'XXXXXXXXXXXXXXXX'))
                    WHEN (event like 'enq%' OR event = 'DFS lock handle') AND state = 'WAITING' THEN 
                '0x'||trim(to_char(p1, 'XXXXXXXXXXXXXXXX'))||': '||
                chr(bitand(p1, -16777216)/16777215)||
                chr(bitand(p1,16711680)/65535)||
                ' mode '||bitand(p1, power(2,14)-1)
            WHEN event like 'latch%' AND state = 'WAITING' THEN 
                  '0x'||trim(to_char(p1, 'XXXXXXXXXXXXXXXX'))||': '||(
                        select name||'[par' 
                            from v$latch_parent 
                            where addr = hextoraw(trim(to_char(p1,rpad('0',length(rawtohex(addr)),'X'))))
                        union all
                        select name||'[c'||child#||']' 
                            from v$latch_children 
                            where addr = hextoraw(trim(to_char(p1,rpad('0',length(rawtohex(addr)),'X'))))
                  )
            WHEN event like 'library cache pin' THEN
                  '0x'||RAWTOHEX(p1raw)
        ELSE NULL END 
    ELSE NULL END AS sw_p1transl
FROM 
    v$session_wait 
WHERE 
    sid IN (&1)
ORDER BY
    state,
    sw_event,
    p1,
    p2,
    p3
/
