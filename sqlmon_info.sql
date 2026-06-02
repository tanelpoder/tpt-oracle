-- Copyright 2025 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- File:  sqlmon_info.sql
-- Usage: @sqlmon_info <SQL_ID> 
--
-- NOTES:
--   1) This is an early draft of the final script
--   2) Currently it reports the SQL_IDs monitored execution that has STARTED most recently
--   3) You have to switch to the appropriate PDB to see monitored queries inside a PDB
--
-- DOP downgrade_reasons FROM X$QKSXA_REASON:
--
--  192  query coordinator did not used automatic DOP
--  205  default DOP mismatch
--  209  parallel execution mode DOP mismatch
--  221  number of partitions much greater than DoP
--  223  min number of hash partitions or sub-partitions greater than DoP
--  352  DOP downgrade due to adaptive DOP
--  353  DOP downgrade due to resource manager max DOP
--  354  DOP downgrade due to insufficient number of processes
--  355  DOP downgrade because slaves failed to join
--  517  high NDV estimation of GROUP BY keys compared to DOP


COL sqlmon_plan_op FOR A50
COL plan_line_id HEAD ID FOR 9999
COL process_name HEAD PROCNAME FOR A10

BREAK ON sid ON process_name SKIP 1

SELECT
--    s.sql_id
--  , s.status
--  , s.sql_exec_start
    s.sid
  , s.process_name
  , p.plan_line_id 
  , LPAD(' ', p.plan_depth, ' ') || p.plan_operation || ' ' || p.plan_options sqlmon_plan_op
--  , s.px_is_cross_instance
--  , s.px_maxdop           
--  , s.px_maxdop_instances 
  , s.px_servers_requested px_req
  , s.px_servers_allocated px_alloc
--  , s.key
--  , s.sid
--  , p.sid
  , (SELECT name FROM v$sql_monitor_statname sni WHERE (sni.group_id,sni.id) = (p.otherstat_group_id,p.otherstat_1_id)) otherstat_1 
  , p.otherstat_1_value 
  , (SELECT name FROM v$sql_monitor_statname sni WHERE (sni.group_id,sni.id) = (p.otherstat_group_id,p.otherstat_2_id)) otherstat_2 
  , p.otherstat_2_value 
  , (SELECT name FROM v$sql_monitor_statname sni WHERE (sni.group_id,sni.id) = (p.otherstat_group_id,p.otherstat_3_id)) otherstat_3 
  , p.otherstat_3_value 
  , (SELECT name FROM v$sql_monitor_statname sni WHERE (sni.group_id,sni.id) = (p.otherstat_group_id,p.otherstat_4_id)) otherstat_4 
  , p.otherstat_4_value 
  , (SELECT name FROM v$sql_monitor_statname sni WHERE (sni.group_id,sni.id) = (p.otherstat_group_id,p.otherstat_5_id)) otherstat_5 
  , p.otherstat_5_value 
  , (SELECT name FROM v$sql_monitor_statname sni WHERE (sni.group_id,sni.id) = (p.otherstat_group_id,p.otherstat_6_id)) otherstat_6 
  , p.otherstat_6_value 
  , (SELECT name FROM v$sql_monitor_statname sni WHERE (sni.group_id,sni.id) = (p.otherstat_group_id,p.otherstat_7_id)) otherstat_7 
  , p.otherstat_7_value 
  , (SELECT name FROM v$sql_monitor_statname sni WHERE (sni.group_id,sni.id) = (p.otherstat_group_id,p.otherstat_8_id)) otherstat_8 
  , p.otherstat_8_value 
  , (SELECT name FROM v$sql_monitor_statname sni WHERE (sni.group_id,sni.id) = (p.otherstat_group_id,p.otherstat_9_id)) otherstat_9 
  , p.otherstat_9_value 
  , (SELECT name FROM v$sql_monitor_statname sni WHERE (sni.group_id,sni.id) = (p.otherstat_group_id,p.otherstat_10_id)) otherstat_10
  , p.otherstat_10_value
-- FYI Oracle 26ai has 30 otherstats columns...
FROM
    gv$sql_monitor      s
  , gv$sql_plan_monitor p
WHERE
-- join
    s.inst_id = p.inst_id
AND s.con_id = p.con_id
AND s.key = p.key
-- filter
AND s.con_id = SYS_CONTEXT('userenv', 'con_id')
AND s.sql_id = '&1'
-- AND s.px_qcsid IS NULL -- QC for PX queries (or serial)
-- AND p.otherstat_group_id IS NOT NULL
AND s.sql_exec_start = (SELECT MAX(sql_exec_start) FROM gv$sql_monitor WHERE sql_id='&1')
ORDER BY
    s.key
  , s.sid
  , p.plan_line_id
/

