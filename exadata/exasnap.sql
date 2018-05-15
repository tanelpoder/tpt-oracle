-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
-- File name:   exasnap.sql (Exadata Snapper) BETA
--
-- Purpose:     Display various Exadata IO efficiency metrics of a session
--              from V$SESSTAT. 
--
-- Author:      Tanel Poder ( http://blog.tanelpoder.com | tanel@tanelpoder.com )
--
-- Copyright:   (c) 2012 All Rights Reserved
-- 
-- Usage:      
--              1) TAKE A SNAPSHOT
--                 
--                 SELECT exasnap.begin_snap(<sid>) FROM dual; 
--                   or
--                 SELECT exasnap.begin_snap('<sid>[@<instance#>]') FROM dual; 
--
--              2) Run the measured query in the session you snapshotted
--                 (or just wait for it to run a while)
--
--              3) TAKE A 2ND SNAPSHOT 
--
--                 SELECT exasnap.begin_snap(<sid>) FROM dual; 
--                   or
--                 SELECT exasnap.begin_snap('<sid>[@<instance#>]') FROM dual; 
--     
--              4) REPORT SESSION METRICS
-- 
--                 @exasnap.sql basic <begin_snap> <end_snap>
--                   or
--                 @exasnap.sql % <begin_snap> <end_snap>
--
--              The latter script gives you more output.
--
-- Other:       This is still a pretty raw script in development and will
--              probably change a lot once it reaches v1.0.
--
--              The PX slaves aggregate their metrics back to the QC session
--              once the query completes, so querying the QC session only is
--              ok if you wait for the query to finish (or cancel it) before
--              taking a snapshot. 
--              To measure a query still running, 
--              
--------------------------------------------------------------------------------

SET LINES 999 PAGES 5000 TRIMOUT ON TRIMSPOOL ON TAB OFF

COL ioeff_percentage FOR A52
BREAK ON inst_id SKIP 1 ON SID ON CATEGORY SKIP 1 DUP

-- keep in capital (MB or GB)
DEF unit=MB

-- adjust for MB or GB
DEF divisor=1024*1024

DEF blocksize=8192

DEF asm_mirrors=2

DEFINE nothing =""
PROMPT
PROMPT ---------------------------------------------------------------------------------------------------------------------------------------------&nothing
PROMPT -- Exadata Snapper v0.5 BETA by Tanel Poder @ Enkitec - The Exadata Experts ( http://www.enkitec.com )                                                  
PROMPT ---------------------------------------------------------------------------------------------------------------------------------------------&nothing

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
              TO_NUMBER(EXTRACT(day    from esn2.snap_time - esn1.snap_time))  * 60 * 60 * 24 +
              -- TODO this is not needed
              TO_NUMBER(TO_CHAR(esn2.snap_time,'xFF')) -
              TO_NUMBER(TO_CHAR(esn1.snap_time,'xFF')) snap_seconds -- looks like the last part is buggy but it's too late to figure this out!
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
        AND esn1.snap_id = &2
        AND esn2.snap_id = &3
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
      , ROUND((phyrd_bytes)/(&divisor))                               db_physrd_&unit
      , ROUND((phywr_bytes)/(&divisor))                               db_physwr_&unit
      , ROUND((phyrd_bytes+phywr_bytes)/(&divisor))                   db_physio_&unit
      , ROUND(pred_offloadable_bytes/(&divisor))                      pred_offloadable_&unit
      , ROUND(phyrd_optim_bytes/(&divisor))                           phyrd_optim_&unit
      , ROUND((phyrd_optim_bytes-storidx_saved_bytes)/(&divisor))     phyrd_flash_rd_&unit
      , ROUND(storidx_saved_bytes/(&divisor))                         phyrd_storidx_saved_&unit
      , ROUND((phyrd_bytes-phyrd_optim_bytes)/(&divisor))             spin_disk_rd_&unit
      , ROUND((phyrd_bytes-phyrd_optim_bytes+(phywr_bytes*&asm_mirrors))/(&divisor)) spin_disk_io_&unit
      , ROUND(uncompressed_bytes/(&divisor))                          scanned_uncomp_&unit
      , ROUND(interconnect_bytes/(&divisor))                          total_ic_&unit
      , ROUND(smart_scan_ret_bytes/(&divisor))                        smart_scan_ret_&unit
      , ROUND((interconnect_bytes-smart_scan_ret_bytes)/(&divisor))   non_smart_scan_&unit
      , ROUND(cell_proc_cache_blk * &blocksize / (&divisor))          cell_proc_cache_&unit
      , ROUND(cell_proc_txn_blk * &blocksize / (&divisor))            cell_proc_txn_&unit
      , ROUND(cell_proc_data_blk * &blocksize / (&divisor))           cell_proc_data_&unit
      , ROUND(cell_proc_index_blk * &blocksize / (&divisor))          cell_proc_index_&unit
      , ROUND(curr_gets_cache_blk * &blocksize / (&divisor))          curr_gets_cache_&unit
      , ROUND(cons_gets_cache_blk * &blocksize / (&divisor))          cons_gets_cache_&unit
      , ROUND(curr_gets_direct_blk * &blocksize / (&divisor))         curr_gets_direct_&unit
      , ROUND(cons_gets_direct_blk * &blocksize / (&divisor))         cons_gets_direct_&unit
      , ROUND(cell_bal_cpu_bytes / (&divisor))                        cell_bal_cpu_&unit
      , ROUND(net_to_client_bytes / (&divisor))                       net_to_client_&unit
      , ROUND(net_from_client_bytes / (&divisor))                     net_from_client_&unit
      , chain_fetch_cont_row
      , chain_rows_skipped
      , chain_rows_processed
      , chain_rows_rejected
    FROM sq
),
precalc2 AS (
    SELECT
        inst_id
      , sid
      , db_physio_&unit
      , db_physrd_&unit
      , db_physwr_&unit
      , pred_offloadable_&unit
      , phyrd_optim_&unit
      , phyrd_flash_rd_&unit + spin_disk_rd_&unit phyrd_disk_and_flash_&unit
      , phyrd_flash_rd_&unit
      , phyrd_storidx_saved_&unit
      , spin_disk_io_&unit
      , spin_disk_rd_&unit
      , ((spin_disk_io_&unit - spin_disk_rd_&unit)) AS spin_disk_wr_&unit
      , scanned_uncomp_&unit
      , ROUND((scanned_uncomp_&unit/NULLIF(spin_disk_rd_&unit + phyrd_flash_rd_&unit, 0))*db_physrd_&unit) est_full_uncomp_&unit 
      , total_ic_&unit
      , smart_scan_ret_&unit
      , non_smart_scan_&unit
      , cell_proc_cache_&unit
      , cell_proc_txn_&unit
      , cell_proc_data_&unit
      , cell_proc_index_&unit
      , cell_bal_cpu_&unit
      , curr_gets_cache_&unit
      , cons_gets_cache_&unit
      , curr_gets_direct_&unit
      , cons_gets_direct_&unit
      , net_to_client_&unit
      , net_from_client_&unit
      , chain_fetch_cont_row
      , chain_rows_skipped
      , chain_rows_processed
      , chain_rows_rejected
    FROM
        precalc
),
--SELECT 
--    inst_id
--  , SUM(db_physio_&unit)
--  , SUM(db_physrd_&unit)
--  , SUM(db_physwr_&unit)
--  , SUM(pred_offloadable_&unit)
--  , SUM(phyrd_optim_&unit)
--  , SUM(spin_disk_io_&unit)
--  , SUM(spin_disk_rd_&unit)
--  , SUM(spin_disk_io_&unit - spin_disk_rd_&unit) AS spin_disk_wr_&unit
--  , SUM(scanned_uncomp_&unit)
--  , ROUND(SUM((scanned_uncomp_&unit/spin_disk_rd_&unit)*db_physrd_&unit)) AS est_full_uncomp_&unit 
--  , SUM(total_ic_&unit)
--  , SUM(smart_scan_ret_&unit)
--  , SUM(non_smart_scan_&unit)
--FROM
--    precalc2
--GROUP BY ROLLUP
--    (inst_id)
--/
unpivoted AS (
    SELECT * FROM precalc2
    UNPIVOT (
            &unit
        FOR metric
        IN (
            phyrd_optim_&unit
          , phyrd_disk_and_flash_&unit
          , phyrd_flash_rd_&unit
          , phyrd_storidx_saved_&unit
          , spin_disk_rd_&unit
          , spin_disk_wr_&unit
          , spin_disk_io_&unit
          , db_physrd_&unit 
          , db_physwr_&unit
          , db_physio_&unit
          , scanned_uncomp_&unit
          , est_full_uncomp_&unit
          , non_smart_scan_&unit
          , smart_scan_ret_&unit
          , total_ic_&unit
          , pred_offloadable_&unit
          , cell_proc_cache_&unit
          , cell_proc_txn_&unit
          , cell_proc_data_&unit
          , cell_proc_index_&unit
          , cell_bal_cpu_&unit
          , curr_gets_cache_&unit
          , cons_gets_cache_&unit
          , curr_gets_direct_&unit
          , cons_gets_direct_&unit
          , net_to_client_&unit
          , net_from_client_&unit
          , chain_fetch_cont_row
          , chain_rows_skipped
          , chain_rows_processed
          , chain_rows_rejected
        )
    )
),
metric AS (
    SELECT 'BASIC' type,          'DB_LAYER_IO' category,    'DB_PHYSIO_&unit' name             FROM dual UNION ALL
    SELECT 'BASIC',               'DB_LAYER_IO',             'DB_PHYSRD_&unit'                  FROM dual UNION ALL
    SELECT 'BASIC',               'DB_LAYER_IO',             'DB_PHYSWR_&unit'                  FROM dual UNION ALL
    SELECT 'ADVANCED',            'AVOID_DISK_IO',           'PHYRD_OPTIM_&unit'                FROM dual UNION ALL
    SELECT 'ADVANCED',            'AVOID_DISK_IO',           'PHYRD_DISK_AND_FLASH_&unit'       FROM dual UNION ALL
    SELECT 'BASIC',               'AVOID_DISK_IO',           'PHYRD_FLASH_RD_&unit'             FROM dual UNION ALL        
    SELECT 'BASIC',               'AVOID_DISK_IO',           'PHYRD_STORIDX_SAVED_&unit'        FROM dual UNION ALL        
    SELECT 'BASIC',               'REAL_DISK_IO',            'SPIN_DISK_IO_&unit'               FROM dual UNION ALL
    SELECT 'BASIC',               'REAL_DISK_IO',            'SPIN_DISK_RD_&unit'               FROM dual UNION ALL
    SELECT 'BASIC',               'REAL_DISK_IO',            'SPIN_DISK_WR_&unit'               FROM dual UNION ALL
    SELECT 'ADVANCED',            'COMPRESS',                'SCANNED_UNCOMP_&unit'             FROM dual UNION ALL
    SELECT 'ADVANCED',            'COMPRESS',                'EST_FULL_UNCOMP_&unit'            FROM dual UNION ALL
    SELECT 'BASIC',               'REDUCE_INTERCONNECT',     'PRED_OFFLOADABLE_&unit'           FROM dual UNION ALL
    SELECT 'BASIC',               'REDUCE_INTERCONNECT',     'TOTAL_IC_&unit'                   FROM dual UNION ALL
    SELECT 'BASIC',               'REDUCE_INTERCONNECT',     'SMART_SCAN_RET_&unit'             FROM dual UNION ALL
    SELECT 'BASIC',               'REDUCE_INTERCONNECT',     'NON_SMART_SCAN_&unit'             FROM dual UNION ALL
    SELECT 'ADVANCED',            'CELL_PROC_DEPTH',         'CELL_PROC_CACHE_&unit'            FROM DUAL UNION ALL
    SELECT 'ADVANCED',            'CELL_PROC_DEPTH',         'CELL_PROC_TXN_&unit'              FROM DUAL UNION ALL
    SELECT 'BASIC',               'CELL_PROC_DEPTH',         'CELL_PROC_DATA_&unit'             FROM DUAL UNION ALL
    SELECT 'BASIC',               'CELL_PROC_DEPTH',         'CELL_PROC_INDEX_&unit'            FROM DUAL UNION ALL
    SELECT 'ADVANCED',            'CELL_PROC_DEPTH',         'CELL_BAL_CPU_&unit'               FROM DUAL UNION ALL
    SELECT 'ADVANCED',            'IN_DB_PROCESSING',        'CURR_GETS_CACHE_&unit'            FROM DUAL UNION ALL
    SELECT 'ADVANCED',            'IN_DB_PROCESSING',        'CONS_GETS_CACHE_&unit'            FROM DUAL UNION ALL
    SELECT 'ADVANCED',            'IN_DB_PROCESSING',        'CURR_GETS_DIRECT_&unit'           FROM DUAL UNION ALL
    SELECT 'ADVANCED',            'IN_DB_PROCESSING',        'CONS_GETS_DIRECT_&unit'           FROM DUAL UNION ALL
    SELECT 'BASIC',               'CLIENT_COMMUNICATION',    'NET_TO_CLIENT_&unit'              FROM DUAL UNION ALL
    SELECT 'BASIC',               'CLIENT_COMMUNICATION',    'NET_FROM_CLIENT_&unit'            FROM DUAL UNION ALL
    SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_FETCH_CONT_ROW'             FROM DUAL UNION ALL
    SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_ROWS_SKIPPED'               FROM DUAL UNION ALL
    SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_ROWS_PROCESSED'             FROM DUAL UNION ALL
    SELECT 'ADVANCED',            'FALLBACK_TO_BLOCK_IO',    'CHAIN_ROWS_REJECTED'              FROM DUAL 
)
SELECT
--    inst_id
--  , sid
    category
--  , type
  , metric
  , '|'||RPAD(NVL(RPAD('#', ROUND(&unit / NULLIF( (SELECT MAX(&unit) FROM unpivoted u, metric m WHERE u.metric = m.name AND m.type LIKE UPPER('&1')), 0) * 50 ), '#'), ' '), 50, ' ')||'|'     ioeff_percentage
  , &unit
  , TO_CHAR(ROUND(&unit / (SELECT snap_seconds FROM stats WHERE rownum = 1),1), '9999999.9') AS "    &unit/sec"
FROM
    unpivoted u
  , metric m
WHERE
    u.metric = m.name
AND m.type LIKE UPPER('&1')
/
