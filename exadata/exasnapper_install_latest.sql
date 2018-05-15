-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
-- File name:   exasnapper_install.sql (Exadata Snapper install) BETA
--
-- Purpose:     Install required objects for the Session Snapper for Exadata tool
--
-- Author:      Tanel Poder ( tanel.poder@enkitec.com | @tanelpoder )
--
-- Web:         http://www.enkitec.com | http://blog.tanelpoder.com 
--
-- Copyright:   (c) 2012-2013 Tanel Poder. All Rights Reserved.
-- 
-- Disclaimer:  This script is provided "as is", so no warranties or guarantees are
--              made about its correctness, reliability and safety. Use it at your
--              own risk!
--
-- Install:     1) Make sure that you have SELECT ANY DICTIONARY privileges
--                 or direct SELECT grants on the GV$ views referenced in this
--                 script
--
--              2) Run @exasnapper_install.sql to create the objects
--
-- Usage:       Take a snapshot of a running session (use QC SID if PX):
--
--                a) Monitor a running query - "DBA mode" 
--
--                   SELECT * FROM TABLE(exasnap.display_sid(<sid>, [snap_seconds], [detail_level]));
--
--                   The SID argument can be just a number (SID in local instance) or a remote SID with
--                   @instance after it (like '123@4')
--
--                   SELECT * FROM TABLE(exasnap.display_sid(123));
--                   SELECT * FROM TABLE(exasnap.display_sid('123@4', p_detail=>'%');
--
--                b) Take Before & After snapshots of a query execution - "Developer Mode"
--
--                   1) SELECT exasnap.begin_snap(123) FROM dual;
--                        or
--                      EXEC :begin_snap_id := exasnap.begin_snap(123);
-- 
--                   2) Run your query, wait until it finishes (or CTRL+C)
--
--                   3) SELECT exasnap.end_snap(123) FROM dual;
--                        or
--                      EXEC :end_snap_id := exasnap.end_snap(123);
--
--                   4) SELECT * FROM TABLE(exasnap.display_snap(:begin_snap_id, :end_snap_id, '%'));
--
--
-- Other:       This is still a pretty raw script in development and will
--              probably change a lot once it reaches v1.0.
--   
--              Exadata Snapper doesn't currently purge old data from its repository
--              so if you use this version heavily, you may want to truncate the
--              ex_ tables manually (should reporting get slow). I'll add the 
--              purging feature in the future.
--              
--------------------------------------------------------------------------------

COL snap_name FOR A20
COL snap_time FOR A30
COL snap_type FOR A10
COL taken_by  FOR A10
COL comm      FOR A100

DROP TABLE ex_snapshot;
DROP TABLE ex_session;
DROP TABLE ex_sesstat;
DROP SEQUENCE ex_snap_seq;
DROP PACKAGE exasnap;
DROP TYPE exastat_result_t;
DROP TYPE exastat_result_r;
DROP TYPE exastat_metrics_t;
DROP TYPE exastat_metrics_r;

CREATE SEQUENCE ex_snap_seq ORDER NOCACHE;

CREATE TABLE ex_snapshot (
    snap_id   NUMBER    NOT NULL
  , snap_time TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
  , snap_name VARCHAR2(100) NOT NULL
  , snap_type VARCHAR2(100) NOT NULL
  , taken_by  VARCHAR2(100) DEFAULT user NOT NULL
  , comm      VARCHAR2(4000)
)
/

ALTER TABLE ex_snapshot ADD CONSTRAINT ex_snapshot_pk PRIMARY KEY (snap_id);

CREATE TABLE ex_session (
    snap_id                                  NUMBER         NOT NULL
  , snap_time                                TIMESTAMP      NOT NULL
  , inst_id                                  NUMBER         NOT NULL
  , sid                                      NUMBER         NOT NULL
  , serial#                                  NUMBER         NOT NULL
  , qc_inst                                  NUMBER
  , qc_sid                                   NUMBER
  , qc_serial#                               NUMBER
  , username                                 VARCHAR2(100)
  , sql_id                                   VARCHAR2(100)
  , dfo_tree                                 NUMBER
  , server_set                               NUMBER
  , server#                                  NUMBER
  , actual_degree                            NUMBER
  , requested_degree                         NUMBER
  , server_name                              VARCHAR2(100)
  , spid                                     VARCHAR2(100)
)
/

ALTER TABLE ex_session ADD CONSTRAINT ex_session_pk PRIMARY KEY (snap_id, inst_id, sid, serial#);


CREATE TABLE ex_sesstat (
    snap_id   NUMBER    NOT NULL
  , snap_time TIMESTAMP NOT NULL
  , inst_id   NUMBER    NOT NULL
  , sid       NUMBER    NOT NULL
  , serial#   NUMBER    NOT NULL
  , stat_name VARCHAR2(100) NOT NULL
  , value     NUMBER    NOT NULL
)
/

ALTER TABLE ex_sesstat ADD CONSTRAINT ex_sesstat_pk PRIMARY KEY (snap_id, inst_id, sid, serial#, stat_name);

CREATE OR REPLACE TYPE exastat_result_r AS OBJECT (name VARCHAR2(1000));
/

CREATE OR REPLACE TYPE exastat_result_t AS TABLE OF exastat_result_r;
/

CREATE OR REPLACE TYPE exastat_metrics_r AS OBJECT (
    inst_id               NUMBER
  , sid                   NUMBER
  , type                  VARCHAR2(20)
  , category              VARCHAR2(25)
  , name                  VARCHAR2(30)
  , delta_value           NUMBER
  , delta_value_per_sec   NUMBER
  , seconds_in_snap       NUMBER
);
/
CREATE OR REPLACE TYPE exastat_metrics_t AS TABLE OF exastat_metrics_r;
/

CREATE OR REPLACE PACKAGE exasnap AS
    TYPE m_lookuptab_t IS TABLE OF exastat_metrics_r INDEX BY VARCHAR2(100);

    FUNCTION begin_snap(p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user) RETURN NUMBER;
    FUNCTION end_snap  (p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user) RETURN NUMBER;
    FUNCTION take_snap (p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user, p_snap_type IN VARCHAR2 DEFAULT 'SNAP', p_dblink IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

    PROCEDURE begin_snap(p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user);
    PROCEDURE end_snap  (p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user); 
    PROCEDURE take_snap (p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user, p_snap_type IN VARCHAR2 DEFAULT 'SNAP'); 

    FUNCTION get_delta_metrics(p_begin_snap IN NUMBER DEFAULT NULL, p_end_snap IN NUMBER DEFAULT NULL) RETURN exastat_metrics_t;
    FUNCTION display_snap(p_begin_snap IN NUMBER DEFAULT NULL, p_end_snap IN NUMBER DEFAULT NULL, p_detail IN VARCHAR2 DEFAULT 'BASIC' ) RETURN exastat_result_t PIPELINED;
    FUNCTION get_sid(p_sid IN VARCHAR2, p_interval IN NUMBER DEFAULT 5) RETURN exastat_metrics_t;
    FUNCTION display_sid(p_sid IN VARCHAR2, p_interval IN NUMBER DEFAULT 5, p_detail IN VARCHAR2 DEFAULT 'BASIC') RETURN exastat_result_t PIPELINED;
    FUNCTION monitor_sid(p_sid IN VARCHAR2, p_interval IN NUMBER DEFAULT 5, p_detail IN VARCHAR2 DEFAULT 'BASIC') RETURN exastat_result_t PIPELINED;

END exasnap;
/
SHOW ERR;

-- main
CREATE OR REPLACE PACKAGE BODY exasnap AS


    FUNCTION begin_snap(p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user) RETURN NUMBER IS
    BEGIN
        RETURN take_snap(p_sid, p_name, 'BEGIN');
    END begin_snap;

    FUNCTION end_snap(p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user) RETURN NUMBER IS
    BEGIN
        RETURN take_snap(p_sid, p_name, 'END');
    END end_snap;

    FUNCTION take_snap(p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user, p_snap_type IN VARCHAR2 DEFAULT 'SNAP', p_dblink IN VARCHAR2 DEFAULT NULL) 
      RETURN NUMBER IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        seq        NUMBER;
        ts         TIMESTAMP := SYSTIMESTAMP;
        lv_sid     NUMBER := TO_NUMBER(REGEXP_SUBSTR(p_sid, '^\d+'));
        lv_inst_id NUMBER := NVL(REPLACE(REGEXP_SUBSTR(p_sid, '@\d+'), '@', ''),SYS_CONTEXT('USERENV','INSTANCE'));
    BEGIN
        SELECT ex_snap_seq.NEXTVAL INTO seq FROM dual;
 
        INSERT INTO ex_snapshot VALUES (seq, ts, p_name, p_snap_type, user, NULL);

        INSERT INTO ex_session
        SELECT
            seq
          , ts
          , pxs.inst_id         
          , pxs.sid             
          , pxs.serial#         
          , pxs.qcinst_id       qc_inst
          , pxs.qcsid           qc_sid
          , pxs.qcserial#       qc_serial#
          , s.username          username
          , s.sql_id
          , pxs.server_group    dfo_tree
          , pxs.server_set
          , pxs.server#
          , pxs.degree          actual_degree
          , pxs.req_degree      requested_degree
          , p.server_name
          , p.spid
        FROM
            gv$px_session pxs
          , gv$session    s
          , gv$px_process p
        WHERE
            pxs.qcsid = lv_sid
        AND pxs.qcinst_id = lv_inst_id
        --AND s.sid     = pxs.qcsid
        AND s.sid     = pxs.sid
        AND s.serial# = pxs.serial#
        --AND s.serial# = pxs.qcserial# -- null
        AND p.sid     = pxs.sid
        AND pxs.inst_id = s.inst_id
        AND s.inst_id = p.inst_id
        UNION ALL
        SELECT
            seq
          , ts
          , s.inst_id         
          , s.sid              
          , s.serial#
          , null -- qcinst
          , null -- qcsid
          , null -- qcserial
          , s.username
          , s.sql_id
          , null -- dfo_tree (server_group)
          , null -- server_set
          , null -- server#
          , null -- degree
          , null -- req_degree
          , s.program -- server_name
          , p.spid
        FROM
            gv$session s
          , gv$process p
        WHERE
            s.inst_id = p.inst_id
        AND s.paddr = p.addr
        AND s.sid = lv_sid
        AND s.inst_id = lv_inst_id;

        INSERT INTO ex_sesstat
        SELECT
            seq
          , ts
          , ss.inst_id
          , ss.sid
          , s.serial# 
          , sn.name stat_name
          , ss.value
        FROM
            gv$sesstat ss
          , gv$statname sn
          , gv$session s
        WHERE
            ss.inst_id = s.inst_id
        AND ss.inst_id = sn.inst_id
        AND s.inst_id = sn.inst_id
        AND s.sid = ss.sid
        AND sn.statistic# = ss.statistic#
        AND (s.inst_id, s.sid, s.serial#) IN (SELECT inst_id, sid, serial# FROM ex_session WHERE snap_id = seq)
        AND (ss.inst_id, ss.sid) IN (SELECT inst_id, sid FROM ex_session WHERE snap_id = seq);

        IF p_snap_type IN ('BEGIN','END') THEN
            NULL;
        ELSE
            NULL;
        END IF;

        COMMIT;

        RETURN seq;
    END take_snap;

    PROCEDURE begin_snap(p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user) IS
       tmp_id NUMBER;
    BEGIN
       tmp_id := begin_snap(p_sid);
    END begin_snap;

    PROCEDURE end_snap(p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user) IS
       tmp_id NUMBER;
    BEGIN
       tmp_id := end_snap(p_sid);
    END end_snap;

    PROCEDURE take_snap(p_sid IN VARCHAR2 DEFAULT TO_CHAR(SYS_CONTEXT('userenv','sid')), p_name IN VARCHAR2 DEFAULT user, p_snap_type IN VARCHAR2 DEFAULT 'SNAP') IS
       tmp_id NUMBER;
    BEGIN
       tmp_id := take_snap(p_sid, p_name, 'SNAP');
    END take_snap;

    FUNCTION get_delta_metrics(p_begin_snap IN NUMBER DEFAULT NULL, p_end_snap IN NUMBER DEFAULT NULL) RETURN exastat_metrics_t IS
       lv_m exastat_metrics_t; 
       lv_blocksize   NUMBER := 8192;
       lv_asm_mirrors NUMBER := 2;
    BEGIN
        WITH stats AS (
            SELECT
                stat_name name
              , SUM(delta) value
              , AVG(snap_seconds) snap_seconds -- is the same for all records in this snap_id
            FROM (
                SELECT
                    esn1.snap_id
                  , esn1.snap_time begin_snap_time
                  , esn2.snap_time end_snap_time
                  , esn2.snap_time - esn1.snap_time snap_interval
                  ,   TO_NUMBER(EXTRACT(second from esn2.snap_time - esn1.snap_time)) +
                      TO_NUMBER(EXTRACT(minute from esn2.snap_time - esn1.snap_time))  * 60 + 
                      TO_NUMBER(EXTRACT(hour   from esn2.snap_time - esn1.snap_time))  * 60 * 60 + 
                      TO_NUMBER(EXTRACT(day    from esn2.snap_time - esn1.snap_time))  * 60 * 60 * 24 snap_seconds
                  , esn1.snap_name begin_snap_name
                  , esn2.snap_name end_snap_name
                  , ess1.stat_name
                  , ess1.value begin_value
                  , ess2.value end_value
                  , ess2.value - ess1.value delta
                FROM
                    ex_snapshot esn1
                  , ex_session  es1
                  , ex_sesstat  ess1
                  , ex_snapshot esn2
                  , ex_session  es2
                  , ex_sesstat  ess2
                WHERE
                -- snap_id
                    esn1.snap_id = es1.snap_id
                AND ess1.snap_id = esn1.snap_id
                AND es1.snap_id  = ess1.snap_id
                AND es1.inst_id  = ess1.inst_id
                AND es1.sid      = ess1.sid
                AND es1.serial#  = ess1.serial#
                --
                AND esn2.snap_id = es2.snap_id
                AND es2.snap_id  = ess2.snap_id
                AND ess2.snap_id = esn2.snap_id
                AND es2.inst_id  = ess2.inst_id
                AND es2.sid      = ess2.sid
                AND es2.serial#  = ess2.serial#
                AND ess1.stat_name = ess2.stat_name
                AND ess1.inst_id = ess2.inst_id
                AND ess1.sid = ess2.sid
                AND ess1.serial# = ess2.serial#
                --
                AND esn1.snap_id = p_begin_snap
                AND esn2.snap_id = p_end_snap
                --
                -- AND ess2.value - ess1.value != 0 -- for testing
            )
            GROUP BY
                stat_name
        ),
        sq AS (
            SELECT
                *
            FROM (
                SELECT
                    0 inst_id
                  , 0 sid
                  , CASE WHEN TRIM(name) IN (
                        'cell physical IO bytes sent directly to DB node to balance CPU'
                      , 'cell physical IO bytes pushed back due to excessive CPU on cell'
                      , 'cell physical IO bytes sent directly to DB node to balanceCPU u'
                    ) THEN
                        'cell physical IO bytes sent directly to DB node to balance CPU'
                    ELSE name
                    END name
                  , value
                FROM
                    --gv$sesstat NATURAL JOIN v$statname
                    stats
                WHERE
                   1=1
                -- AND (name LIKE 'cell%bytes%' OR name LIKE 'physical%bytes%')
                AND TRIM(name) IN (
                     'physical read total bytes'                                 
                   , 'physical write total bytes'                                
                   , 'physical read total bytes optimized'                       
                   , 'cell physical IO bytes eligible for predicate offload'     
                   , 'cell physical IO interconnect bytes'                       
                   , 'cell physical IO interconnect bytes returned by smart scan'
                   , 'cell physical IO bytes saved by storage index'             
                   , 'cell IO uncompressed bytes'                                
                   , 'cell blocks processed by cache layer'                      
                   , 'cell blocks processed by txn layer'                        
                   , 'cell blocks processed by data layer'                       
                   , 'cell blocks processed by index layer'                      
                   , 'db block gets from cache'                                  
                   , 'consistent gets from cache' 
                   , 'db block gets direct'                                  
                   , 'consistent gets direct' 
                   -- following three stats are the same thing (named differently in different versions)
                   , 'cell physical IO bytes sent directly to DB node to balance CPU'
                   , 'cell physical IO bytes pushed back due to excessive CPU on cell'
                   , 'cell physical IO bytes sent directly to DB node to balanceCPU u'                               
                   , 'bytes sent via SQL*Net to client'
                   , 'bytes received via SQL*Net from client'
                   , 'table fetch continued row'
                   , 'chained rows skipped by cell'
                   , 'chained rows processed by cell'
                   , 'chained rows rejected by cell'
                )
            )
            PIVOT (
                SUM(value)
            FOR name IN (
                    'physical read total bytes'                                      AS phyrd_bytes
                  , 'physical write total bytes'                                     AS phywr_bytes
                  , 'physical read total bytes optimized'                            AS phyrd_optim_bytes
                  , 'cell physical IO bytes eligible for predicate offload'          AS pred_offloadable_bytes
                  , 'cell physical IO interconnect bytes'                            AS interconnect_bytes 
                  , 'cell physical IO interconnect bytes returned by smart scan'     AS smart_scan_ret_bytes
                  , 'cell physical IO bytes saved by storage index'                  AS storidx_saved_bytes
                  , 'cell IO uncompressed bytes'                                     AS uncompressed_bytes
                  , 'cell blocks processed by cache layer'                           AS cell_proc_cache_blk
                  , 'cell blocks processed by txn layer'                             AS cell_proc_txn_blk
                  , 'cell blocks processed by data layer'                            AS cell_proc_data_blk
                  , 'cell blocks processed by index layer'                           AS cell_proc_index_blk
                  , 'db block gets from cache'                                       AS curr_gets_cache_blk
                  , 'consistent gets from cache'                                     AS cons_gets_cache_blk
                  , 'db block gets direct'                                           AS curr_gets_direct_blk
                  , 'consistent gets direct'                                         AS cons_gets_direct_blk
                  , 'cell physical IO bytes sent directly to DB node to balance CPU' AS cell_bal_cpu_bytes
                  , 'bytes sent via SQL*Net to client'                               AS net_to_client_bytes
                  , 'bytes received via SQL*Net from client'                         AS net_from_client_bytes
                  , 'table fetch continued row'                                      AS chain_fetch_cont_row
                  , 'chained rows skipped by cell'                                   AS chain_rows_skipped
                  , 'chained rows processed by cell'                                 AS chain_rows_processed
                  , 'chained rows rejected by cell'                                  AS chain_rows_rejected
                ) 
            ) 
        ),
        precalc AS (
            SELECT 
                inst_id
              , sid
              , (phyrd_bytes)                                                   db_physrd_BYTES
              , (phywr_bytes)                                                   db_physwr_BYTES
              , (phyrd_bytes+phywr_bytes)                                       db_physio_BYTES
              , pred_offloadable_bytes                                          pred_offloadable_BYTES
              , phyrd_optim_bytes                                               phyrd_optim_BYTES
              , (phyrd_optim_bytes-storidx_saved_bytes)                         phyrd_flash_rd_BYTES
              , storidx_saved_bytes                                             phyrd_storidx_saved_BYTES
              , (phyrd_bytes-phyrd_optim_bytes)                                 spin_disk_rd_BYTES
              , (phyrd_bytes-phyrd_optim_bytes+(phywr_bytes*lv_asm_mirrors))    spin_disk_io_BYTES
              , uncompressed_bytes                                              scanned_uncomp_BYTES
              , interconnect_bytes                                              total_ic_BYTES
              , smart_scan_ret_bytes                                            smart_scan_ret_BYTES
              , (interconnect_bytes-smart_scan_ret_bytes)                       non_smart_scan_BYTES
              , (cell_proc_cache_blk  * lv_blocksize)                           cell_proc_cache_BYTES
              , (cell_proc_txn_blk    * lv_blocksize)                           cell_proc_txn_BYTES
              , (cell_proc_data_blk   * lv_blocksize)                           cell_proc_data_BYTES
              , (cell_proc_index_blk  * lv_blocksize)                           cell_proc_index_BYTES
              , (curr_gets_cache_blk  * lv_blocksize)                           curr_gets_cache_BYTES
              , (cons_gets_cache_blk  * lv_blocksize)                           cons_gets_cache_BYTES
              , (curr_gets_direct_blk * lv_blocksize)                           curr_gets_direct_BYTES
              , (cons_gets_direct_blk * lv_blocksize)                           cons_gets_direct_BYTES
              , cell_bal_cpu_bytes                                              cell_bal_cpu_BYTES
              , net_to_client_bytes                                             net_to_client_BYTES
              , net_from_client_bytes                                           net_from_client_BYTES
              , chain_fetch_cont_row
              , chain_rows_skipped
              , chain_rows_processed
              , chain_rows_rejected
              , (chain_rows_skipped    * lv_blocksize)                           chain_blocks_skipped
              , (chain_rows_processed  * lv_blocksize)                           chain_blocks_processed
              , (chain_rows_rejected   * lv_blocksize)                           chain_blocks_rejected
            FROM sq
        ),
        precalc2 AS (
            SELECT
                inst_id
              , sid
              , db_physio_BYTES
              , db_physrd_BYTES
              , db_physwr_BYTES
              , pred_offloadable_BYTES
              , phyrd_optim_BYTES
              , phyrd_flash_rd_BYTES + spin_disk_rd_BYTES phyrd_disk_and_flash_BYTES
              , phyrd_flash_rd_BYTES
              , phyrd_storidx_saved_BYTES
              , spin_disk_io_BYTES
              , spin_disk_rd_BYTES
              , ((spin_disk_io_BYTES - spin_disk_rd_BYTES)) AS spin_disk_wr_BYTES
              , scanned_uncomp_BYTES
              , ROUND((scanned_uncomp_BYTES/NULLIF(phyrd_flash_rd_BYTES+spin_disk_rd_BYTES, 0))*db_physrd_BYTES) est_full_uncomp_BYTES 
              , total_ic_BYTES
              , smart_scan_ret_BYTES
              , non_smart_scan_BYTES
              , cell_proc_cache_BYTES
              , cell_proc_txn_BYTES
              , cell_proc_data_BYTES
              , cell_proc_index_BYTES
              , cell_bal_cpu_BYTES
              , curr_gets_cache_BYTES
              , cons_gets_cache_BYTES
              , curr_gets_direct_BYTES
              , cons_gets_direct_BYTES
              , net_to_client_BYTES
              , net_from_client_BYTES
              , chain_fetch_cont_row
              , chain_rows_skipped
              , chain_rows_processed
              , chain_rows_rejected
              , chain_blocks_skipped
              , chain_blocks_processed
              , chain_blocks_rejected
            FROM
                precalc
        ),
        unpivoted AS (
            SELECT * FROM precalc2
            UNPIVOT (
                    BYTES
                FOR metric
                IN (
                    phyrd_optim_BYTES
                  , phyrd_disk_and_flash_BYTES
                  , phyrd_flash_rd_BYTES
                  , phyrd_storidx_saved_BYTES
                  , spin_disk_rd_BYTES
                  , spin_disk_wr_BYTES
                  , spin_disk_io_BYTES
                  , db_physrd_BYTES 
                  , db_physwr_BYTES
                  , db_physio_BYTES
                  , scanned_uncomp_BYTES
                  , est_full_uncomp_BYTES
                  , non_smart_scan_BYTES
                  , smart_scan_ret_BYTES
                  , total_ic_BYTES
                  , pred_offloadable_BYTES
                  , cell_proc_cache_BYTES
                  , cell_proc_txn_BYTES
                  , cell_proc_data_BYTES
                  , cell_proc_index_BYTES
                  , cell_bal_cpu_BYTES
                  , curr_gets_cache_BYTES
                  , cons_gets_cache_BYTES
                  , curr_gets_direct_BYTES
                  , cons_gets_direct_BYTES
                  , net_to_client_BYTES
                  , net_from_client_BYTES
                  , chain_fetch_cont_row
                  , chain_rows_skipped
                  , chain_rows_processed
                  , chain_rows_rejected
                  , chain_blocks_skipped
                  , chain_blocks_processed
                  , chain_blocks_rejected
                )
            )
        ),
        metric AS (
            SELECT 'BASIC' type,          'DB_LAYER_IO' category,    'DB_PHYSIO_BYTES' name             FROM dual UNION ALL             
            SELECT 'BASIC',               'DB_LAYER_IO',             'DB_PHYSRD_BYTES'                  FROM dual UNION ALL
            SELECT 'BASIC',               'DB_LAYER_IO',             'DB_PHYSWR_BYTES'                  FROM dual UNION ALL
            SELECT 'ADVANCED',            'AVOID_DISK_IO',           'PHYRD_OPTIM_BYTES'                FROM dual UNION ALL
            SELECT 'ADVANCED',            'AVOID_DISK_IO',           'PHYRD_DISK_AND_FLASH_BYTES'       FROM dual UNION ALL
            SELECT 'BASIC',               'AVOID_DISK_IO',           'PHYRD_FLASH_RD_BYTES'             FROM dual UNION ALL 
            SELECT 'BASIC',               'AVOID_DISK_IO',           'PHYRD_STORIDX_SAVED_BYTES'        FROM dual UNION ALL
            SELECT 'BASIC',               'REAL_DISK_IO',            'SPIN_DISK_IO_BYTES'               FROM dual UNION ALL
            SELECT 'BASIC',               'REAL_DISK_IO',            'SPIN_DISK_RD_BYTES'               FROM dual UNION ALL
            SELECT 'BASIC',               'REAL_DISK_IO',            'SPIN_DISK_WR_BYTES'               FROM dual UNION ALL
            SELECT 'ADVANCED',            'COMPRESS',                'SCANNED_UNCOMP_BYTES'             FROM dual UNION ALL
            SELECT 'ADVANCED',            'COMPRESS',                'EST_FULL_UNCOMP_BYTES'            FROM dual UNION ALL
            SELECT 'BASIC',               'REDUCE_INTERCONNECT',     'PRED_OFFLOADABLE_BYTES'           FROM dual UNION ALL
            SELECT 'BASIC',               'REDUCE_INTERCONNECT',     'TOTAL_IC_BYTES'                   FROM dual UNION ALL
            SELECT 'BASIC',               'REDUCE_INTERCONNECT',     'SMART_SCAN_RET_BYTES'             FROM dual UNION ALL
            SELECT 'BASIC',               'REDUCE_INTERCONNECT',     'NON_SMART_SCAN_BYTES'             FROM dual UNION ALL
            SELECT 'ADVANCED',            'CELL_PROC_DEPTH',         'CELL_PROC_CACHE_BYTES'            FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'CELL_PROC_DEPTH',         'CELL_PROC_TXN_BYTES'              FROM DUAL UNION ALL
            SELECT 'BASIC',               'CELL_PROC_DEPTH',         'CELL_PROC_DATA_BYTES'             FROM DUAL UNION ALL
            SELECT 'BASIC',               'CELL_PROC_DEPTH',         'CELL_PROC_INDEX_BYTES'            FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'CELL_PROC_DEPTH',         'CELL_BAL_CPU_BYTES'               FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'IN_DB_PROCESSING',        'CURR_GETS_CACHE_BYTES'            FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'IN_DB_PROCESSING',        'CONS_GETS_CACHE_BYTES'            FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'IN_DB_PROCESSING',        'CURR_GETS_DIRECT_BYTES'           FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'IN_DB_PROCESSING',        'CONS_GETS_DIRECT_BYTES'           FROM DUAL UNION ALL
            SELECT 'BASIC',               'CLIENT_COMMUNICATION',    'NET_TO_CLIENT_BYTES'              FROM DUAL UNION ALL
            SELECT 'BASIC',               'CLIENT_COMMUNICATION',    'NET_FROM_CLIENT_BYTES'            FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_FETCH_CONT_ROW'             FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_ROWS_SKIPPED'               FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_ROWS_PROCESSED'             FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_ROWS_REJECTED'              FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_BLOCKS_SKIPPED'             FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_BLOCKS_PROCESSED'           FROM DUAL UNION ALL
            SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_BLOCKS_REJECTED'            FROM DUAL 
        )
        SELECT
            exastat_metrics_r (
            inst_id
          , sid
          , type
          , category
          , metric
          , bytes
          , bytes_sec
          , seconds_in_snap 
        )
        BULK COLLECT INTO lv_m 
        FROM (
            SELECT 
                inst_id
              , sid
              , type
              , category
              , metric
              , bytes
              , BYTES / (SELECT snap_seconds FROM stats WHERE rownum = 1) bytes_sec
              , (SELECT snap_seconds FROM stats WHERE rownum = 1) seconds_in_snap 
            FROM
                unpivoted u
              , metric m
            WHERE
                u.metric = m.name
        )
        ;

      RETURN lv_m;

    END get_delta_metrics;

    FUNCTION gen_lookuptab(p_metrics IN exastat_metrics_t) RETURN m_lookuptab_t IS
        lv_m m_lookuptab_t;
        lv_m_id VARCHAR2(100);
    BEGIN
        FOR i IN 1 .. p_metrics.COUNT LOOP
            lv_m_id := TRIM(TO_CHAR(p_metrics(i).inst_id))||','
                    || TRIM(TO_CHAR(p_metrics(i).sid    ))||','
                    || TRIM(        p_metrics(i).name    );
            lv_m(lv_m_id) := p_metrics(i);
        END LOOP;
        RETURN lv_m;
    END;

    FUNCTION display_snap(p_begin_snap IN NUMBER DEFAULT NULL, p_end_snap IN NUMBER DEFAULT NULL, p_detail IN VARCHAR2 DEFAULT 'BASIC' ) RETURN exastat_result_t PIPELINED IS
        ml m_lookuptab_t;
        m  exastat_metrics_t;
        str VARCHAR2(200);
        max_bytes NUMBER;
    BEGIN
        ml := gen_lookuptab(get_delta_metrics(p_begin_snap, p_end_snap));
        m := get_delta_metrics(p_begin_snap, p_end_snap);

        SELECT MAX(delta_value) INTO max_bytes FROM TABLE(CAST(m AS exastat_metrics_t)) WHERE type LIKE p_detail;

        str := '-- ExaSnapper v0.81 BETA by Tanel Poder @ Enkitec - The Exadata Experts ( http://www.enkitec.com )';                                                 
        PIPE ROW(exastat_result_r(str));
        str := LPAD('-',153,'-');
        PIPE ROW(exastat_result_r(str));

        FOR i IN 1..m.COUNT LOOP
            IF m(i).type LIKE p_detail THEN
                str := RPAD(m(i).category, 30)||' '||RPAD(m(i).name, 30)||'|'|| RPAD(NVL(RPAD('#', ROUND(m(i).delta_value / NULLIF(max_bytes , 0) * 50 ), '#'), ' '), 50, ' ')||'|';
                str := str || LPAD(ROUND(m(i).delta_value/1048576), 15) ||' MB';
                str := str || LPAD(ROUND(m(i).delta_value_per_sec/1048576), 15) ||' MB/sec';
                PIPE ROW(exastat_result_r(str));
            END IF;
        END LOOP;
    END display_snap;

    FUNCTION get_sid(p_sid IN VARCHAR2, p_interval IN NUMBER DEFAULT 5) RETURN exastat_metrics_t IS
        lv_begin NUMBER;
        lv_end   NUMBER;
    BEGIN
        lv_begin := BEGIN_SNAP(p_sid);
        DBMS_LOCK.SLEEP(p_interval);
        lv_end   := END_SNAP(p_sid);
        RETURN get_delta_metrics(lv_begin, lv_end);
    END get_sid;

    FUNCTION display_sid(p_sid IN VARCHAR2, p_interval IN NUMBER DEFAULT 5, p_detail IN VARCHAR2 DEFAULT 'BASIC') RETURN exastat_result_t PIPELINED IS 
        m  exastat_metrics_t;
        str VARCHAR2(200);
        max_bytes NUMBER;
    BEGIN
        m := get_sid(p_sid, p_interval);

        SELECT MAX(delta_value) INTO max_bytes FROM TABLE(CAST(m AS exastat_metrics_t)) WHERE type LIKE p_detail;

        str := '-- ExaSnapper v0.81 BETA by Tanel Poder @ Enkitec - The Exadata Experts ( http://www.enkitec.com )';
        PIPE ROW(exastat_result_r(str));
        str := LPAD('-',153,'-');
        PIPE ROW(exastat_result_r(str));

        FOR i IN 1..m.COUNT LOOP
            IF m(i).type LIKE p_detail THEN
                str := RPAD(m(i).category, 30)||' '||RPAD(m(i).name, 30)||'|'|| RPAD(NVL(RPAD('#', ROUND(m(i).delta_value / NULLIF(max_bytes , 0) * 50 ), '#'), ' '), 50, ' ')||'|';
                str := str || LPAD(ROUND(m(i).delta_value/1048576), 15) ||' MB';
                str := str || LPAD(ROUND(m(i).delta_value_per_sec/1048576), 15) ||' MB/sec';
                PIPE ROW(exastat_result_r(str));
            END IF;
        END LOOP;
    END display_sid;

    -- experimental. set arraysize 64. TODO requires in-mem sampling
    FUNCTION monitor_sid(p_sid IN VARCHAR2, p_interval IN NUMBER DEFAULT 5, p_detail IN VARCHAR2 DEFAULT 'BASIC') RETURN exastat_result_t PIPELINED IS 
    BEGIN
        WHILE TRUE LOOP
            FOR c IN 1..30 LOOP PIPE ROW (exastat_result_r('')); END LOOP;
            PIPE ROW (exastat_result_r('INST='||SYS_CONTEXT('userenv', 'instance_name')||' TIME='||TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS')));
            FOR r IN (SELECT name FROM TABLE(display_sid(p_sid, p_interval, p_detail))) LOOP
                PIPE ROW(exastat_result_r(r.name));
            END LOOP;
        END LOOP;
        
    END monitor_sid;

END exasnap;
/

SHOW ERR;

