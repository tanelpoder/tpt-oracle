-- vstat.sql by Tanel Poder v0.3 (beta)

PROMPT
PROMPT vstat.sql: Show system metrics with per-minute granularity for current container/PDB
PROMPT Only last hour is shown in gv$sysmetric_history (use awr/dstat.sql for AWR history)

COL AAS           HEAD "(#ses)|AAS"       FOR 9999.9
COL SBRLATms      HEAD "(ms)|SBRLAT"      FOR 99.90
COL DBCPU         HEAD "(%aCPU)|DBCPU"    FOR 99999.90 
COL BGCPU         HEAD "(%aCPU)|BGCPU"    FOR 99999.90 
COL OSCPU         HEAD "(%aCPU)|OSCPU"    FOR 99999.90 
COL IOSIZE        HEAD "(kB)|IOSIZE"      FOR 99999
COL "BLKCHG/tx"   HEAD "BLKCHG/tx"        FOR 9999999.0
COL "REDOKB/s"    HEAD "(kB/s)|REDOKB/s"  FOR 9999999.0
COL "NETKB/s"     HEAD "(kB/s)|NETKB/s"   FOR 9999999.0
COL "IOMB/s"      HEAD "(MB/s)|IOMB/s"    FOR 999999.0
COL "IOPS"        HEAD "IOPS"             FOR 99999999
COL "LOGONS/s"    HEAD "LOGONS/s"         FOR 99999.0
COL "EXECS/s"     HEAD "EXECS/s"          FOR 999999.0

COL "PARSE/tx"    HEAD "PARSE/tx" FOR 9999999.0
COL "UCALLS/s"    HEAD "UCALLS/s" FOR 9999999.0
COL "BLKRD/s"     HEAD "BLKRD/s"  FOR 9999999.0
COL "BLKWR/s"     HEAD "BLKWR/s"  FOR 9999999.0
COL "REDO/tx"     HEAD "(kB)|REDO/tx"  FOR 9999999.0
COL "PARSE/tx"    HEAD "PARSE/tx" FOR 9999999.0
COL "SQLMS/call"  HEAD "(ms)|SQLms/call" FOR 9999999.0
COL "RESPMS/tx"   HEAD "(ms)|RESPms/tx" FOR 9999999.0
COL "ENQRQ/tx"    HEAD "ENQRQ/tx" FOR 9999999.0

COL "UTRANS/s"    HEAD "UTRANS/s" FOR 9999999.0
COL "BLKRD/tx"    HEAD "BLKRD/tx" FOR 9999999.0

COL dstat_inst     HEAD "I#" FOR 90 
COL dstat_con_name HEAD CON_NAME FOR A30
COL dstat_dbid     HEAD DBID FOR A30

SELECT
    SYS_CONTEXT('userenv', 'con_name') AS dstat_con_name
  , SYS_CONTEXT('userenv', 'dbid') AS dstat_dbid
FROM dual;

-- The MAX() functions below are used just for the metric_name pivot trick with CASE statement
-- we actually will get only one row per grouping, so MAX is ok (ANY_VALUE won't work on 12c)

SELECT
    inst_id AS dstat_inst
  , begin_time
--  , MAX(ROUND(intsize / 100)) seconds
  , ROUND(MAX(CASE WHEN metric_name = 'Average Active Sessions'        THEN value END),2) "AAS"
  , ROUND(MAX(CASE WHEN metric_name = 'Average Synchronous Single-Block Read Latency' THEN value END),2) "SBRLATms"
  , ROUND(MAX(CASE WHEN metric_name = 'CPU Usage Per Sec'              THEN value END),2) "DBCPU"  
  , ROUND(MAX(CASE WHEN metric_name = 'Background CPU Usage Per Sec'   THEN value END),2) "BGCPU"  
  , ROUND(MAX(CASE WHEN metric_name = 'Host CPU Usage Per Sec'         THEN value END),2) "OSCPU"
  , ROUND(MAX(CASE WHEN metric_name = 'Logons Per Sec'                 THEN value END),2) "LOGONS/s"
  , ROUND(MAX(CASE WHEN metric_name = 'Executions Per Sec'             THEN value END),2) "EXECS/s"
  , ROUND(MAX(CASE WHEN metric_name = 'I/O Megabytes per Second'       THEN value END),2) "IOMB/s"
  , ROUND(MAX(CASE WHEN metric_name = 'I/O Requests per Second'        THEN value END),2) "IOPS"
  , ROUND(SUM(CASE WHEN metric_name = 'I/O Megabytes per Second'       THEN value END) * 1024 /
          NULLIF(SUM(CASE WHEN metric_name = 'I/O Requests per Second'        THEN value END), 0), 2) "IOSIZE"
  , ROUND(MAX(CASE WHEN metric_name = 'Logical Reads Per Txn'          THEN value END)) "LIOs/tx"
  , ROUND(MAX(CASE WHEN metric_name = 'DB Block Changes Per Txn'       THEN value END),1) "BLKCHG/tx"
  , ROUND(MAX(CASE WHEN metric_name = 'User Transaction Per Sec'       THEN value END),2) "UTRANS/s" 
  , ROUND(MAX(CASE WHEN metric_name = 'Redo Generated Per Sec'         THEN value END)/1024,2) "REDOKB/s"
  , ROUND(MAX(CASE WHEN metric_name = 'Redo Generated Per Txn'         THEN value END)/1024,2) "REDO/tx"
  , ROUND(MAX(CASE WHEN metric_name = 'Physical Reads Per Sec'         THEN value END),2) "BLKRD/s"
  , ROUND(MAX(CASE WHEN metric_name = 'Physical Writes Per Sec'        THEN value END),2) "BLKWR/s"
  , ROUND(MAX(CASE WHEN metric_name = 'Physical Reads Per Txn'         THEN value END),2) "BLKRD/tx"
  , ROUND(MAX(CASE WHEN metric_name = 'Network Traffic Volume Per Sec' THEN value END)/1024,2) "NETKB/s"
  , ROUND(MAX(CASE WHEN metric_name = 'Total Parse Count Per Txn'      THEN value END),2) "PARSE/tx"
  , ROUND(MAX(CASE WHEN metric_name = 'User Calls Per Sec'             THEN value END),2) "UCALLS/s"
  , ROUND(MAX(CASE WHEN metric_name = 'SQL Service Response Time'      THEN value END) * 10,2) "SQLms/call"
  , ROUND(MAX(CASE WHEN metric_name = 'Response Time Per Txn'          THEN value END) * 10,2) "RESPms/tx"
  , ROUND(MAX(CASE WHEN metric_name = 'Enqueue Requests Per Txn'       THEN value END),2) "ENQRQ/tx"
  --, metric_name
  --, value
  --, metric_unit
FROM
    gv$sysmetric_history h
WHERE
    group_id = 2 -- get 60 sec granularity metrics
AND begin_time >= &1 AND end_time <= &2
GROUP BY
    inst_id
  , begin_time
ORDER BY
    inst_id
  , begin_time
/
