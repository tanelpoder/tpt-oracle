COL swh_sid              HEAD SID FOR 999999
COL swh_username         HEAD USERNAME           FOR A20 TRUNCATE
COL swh_event            HEAD EVENT              FOR A35 WORD_WRAP
COL swh_wait_time_us     HEAD WAIT_TIME_US       FOR 99,999,999,999
COL swh_prev_wait_end_us HEAD CPU_BEFORE_WT_US   FOR 99,999,999,999
COL swh_machine          HEAD MACHINE            FOR A20
COL swh_program          HEAD PROGRAM            FOR A20

BREAK ON swh_sid SKIP 1


PROMPT
PROMPT -- Display last 10 COMPLETED waits from v$session_wait_history v0.1 BETA by Tanel Poder ( https://tanelpoder.com )

SELECT
    s.inst_id
  , s.sid      swh_sid
  , s.username swh_username
  , CASE swh.seq# WHEN 1 THEN s.sql_id WHEN 2 THEN s.prev_sql_id END curr_prev_sql_id
  , s.machine  swh_machine
--  , s.program  swh_program
  , swh.event swh_event
  , swh.seq# waits_ago
  , swh.wait_time_micro swh_wait_time_us
  , swh.time_since_last_wait_micro swh_prev_wait_end_us 
--  , swh.p1text
--  , swh.p1
--  , swh.p2text
--  , swh.p2
--  , swh.p3text
--  , swh.p3
FROM
    -- using an inline view so that the swh.sql script can be called like:
    -- @swh sid=XYZ  ... or @swh username='XYZ' .. or @swh sql_id='xxxxxxxxx'
    (SELECT * FROM gv$session s WHERE &1) s
  , gv$session_wait_history swh 
WHERE
    s.inst_id = swh.inst_id
AND s.sid     = swh.sid
--AND swh.event = 'SQL*Net message from client'
ORDER BY
    s.inst_id
  , s.sid
  , swh.seq#
/

