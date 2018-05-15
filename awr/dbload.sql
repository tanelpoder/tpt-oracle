-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINES 999 PAGES 5000 TRIMSPOOL ON TRIMOUT ON TAB OFF

COL snap_time FOR A30

SELECT
    sn.begin_interval_time snap_time
  , ROUND(SUM(CASE WHEN metric_name = 'Average Active Sessions'                       THEN value END)) aas
  , ROUND(AVG(CASE WHEN metric_name = 'Average Synchronous Single-Block Read Latency' THEN value END)) iolat
  , ROUND(SUM(CASE WHEN metric_name = 'CPU Usage Per Sec'                             THEN value END)) cpusec
  , ROUND(SUM(CASE WHEN metric_name = 'Background CPU Usage Per Sec'                  THEN value END)) bgcpusec
  , ROUND(AVG(CASE WHEN metric_name = 'DB Block Changes Per Txn'                      THEN value END)) blkchgtxn
  , ROUND(SUM(CASE WHEN metric_name = 'Executions Per Sec'                            THEN value END)) execsec
  , ROUND(SUM(CASE WHEN metric_name = 'Host CPU Usage Per Sec'                        THEN value END)) oscpusec 
  , ROUND(SUM(CASE WHEN metric_name = 'I/O Megabytes per Second'                      THEN value END)) iombsec
  , ROUND(SUM(CASE WHEN metric_name = 'I/O Requests per Second'                       THEN value END)) ioreqsec
  , ROUND(AVG(CASE WHEN metric_name = 'Logical Reads Per Txn'                         THEN value END)) liotxn
  , ROUND(SUM(CASE WHEN metric_name = 'Logons Per Sec'                                THEN value END)) logsec
  , ROUND(SUM(CASE WHEN metric_name = 'Network Traffic Volume Per Sec'                THEN value END)/1048576) netmbsec
  , ROUND(SUM(CASE WHEN metric_name = 'Physical Reads Per Sec'                        THEN value END)) phyrdsec
  , ROUND(AVG(CASE WHEN metric_name = 'Physical Reads Per Txn'                        THEN value END)) phyrdtxn
  , ROUND(SUM(CASE WHEN metric_name = 'Physical Writes Per Sec'                       THEN value END)) phywrsec
  , ROUND(SUM(CASE WHEN metric_name = 'Redo Generated Per Sec'                        THEN value END)/1024) redokbsec
  , ROUND(AVG(CASE WHEN metric_name = 'Redo Generated Per Txn'                        THEN value END)/1024) redokbtxn
  , ROUND(AVG(CASE WHEN metric_name = 'Response Time Per Txn'                         THEN value END)*10) timemsectxn
  , ROUND(AVG(CASE WHEN metric_name = 'SQL Service Response Time'                     THEN value END)*10) timemseccall
  , ROUND(AVG(CASE WHEN metric_name = 'Total Parse Count Per Txn'                     THEN value END)) prstxn
  , ROUND(SUM(CASE WHEN metric_name = 'User Calls Per Sec'                            THEN value END)) ucallsec
  , ROUND(SUM(CASE WHEN metric_name = 'User Transaction Per Sec'                      THEN value END)) utxnsec
FROM
    dba_hist_snapshot sn
  , dba_hist_sysmetric_history m
WHERE
    sn.snap_id = m.snap_id
AND sn.dbid    = m.dbid
AND sn.instance_number = m.instance_number
AND sn.begin_interval_time > SYSDATE - 7
GROUP BY
    sn.begin_interval_time
ORDER BY
    sn.begin_interval_time
/

