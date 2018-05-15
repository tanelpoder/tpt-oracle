-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   ioeff.sql
-- Purpose:     Display various Exadata IO efficiency metrics
--              from all Exadata RAC cluster nodes
--              
-- Author:      Tanel Poder
-- Copyright:   (c) 2012 http://blog.tanelpoder.com
--              
-- Usage:       Run ioeff.sql
--
-- Other:       This is still a raw experimental script and doesn't do a good  
--              job with explaining these metrics well yet
--              
--------------------------------------------------------------------------------

SET LINES 999 PAGES 5000 TRIMOUT ON TRIMSPOOL ON TAB OFF

COL ioeff_percentage FOR A52
BREAK ON inst_id SKIP 1

WITH sq AS (
    SELECT
        *
    FROM (
        SELECT inst_id, name, value
        FROM gv$sysstat
        WHERE
            name LIKE 'cell%bytes%'
        OR  name LIKE 'physical%bytes%'
    )
    PIVOT (
        SUM(value)
    FOR name IN (
            'physical read total bytes'                                  AS phyrd_bytes
          , 'physical write total bytes'                                 AS phywr_bytes
          , 'physical read total bytes optimized'                        AS phyrd_optim_bytes
          , 'cell physical IO bytes eligible for predicate offload'      AS pred_offload_bytes
          , 'cell physical IO interconnect bytes'                        AS interconnect_bytes 
          , 'cell physical IO interconnect bytes returned by smart scan' AS smart_scan_ret_bytes
          , 'cell physical IO bytes saved by storage index'              AS storidx_saved_bytes
          , 'cell IO uncompressed bytes'                                 AS uncompressed_bytes
        ) 
    ) 
),
precalc AS (
    SELECT 
        inst_id
      , ROUND((phyrd_bytes)/(1024*1024*1024))                               db_physrd_gb
      , ROUND((phywr_bytes)/(1024*1024*1024))                               db_physwr_gb
      , ROUND((phyrd_bytes+phywr_bytes)/(1024*1024*1024))                   db_physio_gb
      , ROUND(pred_offload_bytes/(1024*1024*1024))                          pred_offload_gb
      , ROUND(phyrd_optim_bytes/(1024*1024*1024))                           phyrd_optim_gb
      , ROUND((phyrd_optim_bytes-storidx_saved_bytes)/(1024*1024*1024))     phyrd_flash_rd_gb
      , ROUND((phyrd_bytes-phyrd_optim_bytes)/(1024*1024*1024))             spin_disk_rd_gb
      , ROUND((phyrd_bytes+phywr_bytes-phyrd_optim_bytes)/(1024*1024*1024)) spin_disk_io_gb
      , ROUND(uncompressed_bytes/(1024*1024*1024))                          scanned_uncomp_gb
      , ROUND(interconnect_bytes/(1024*1024*1024))                          total_ic_gb
      , ROUND(smart_scan_ret_bytes/(1024*1024*1024))                        smart_scan_gb
      , ROUND((interconnect_bytes-smart_scan_ret_bytes)/(1024*1024*1024))   non_smart_scan_gb
    FROM sq
),
precalc2 AS (
    SELECT
        inst_id
      , db_physio_gb
      , db_physrd_gb
      , db_physwr_gb
      , pred_offload_gb
      , phyrd_optim_gb
      , phyrd_flash_rd_gb + spin_disk_rd_gb phyrd_disk_and_flash_gb
      , phyrd_flash_rd_gb
      , spin_disk_io_gb
      , spin_disk_rd_gb
      , spin_disk_io_gb - spin_disk_rd_gb AS spin_disk_wr_gb
      , scanned_uncomp_gb
      , ROUND((scanned_uncomp_gb/spin_disk_rd_gb)*db_physrd_gb) est_full_uncomp_gb 
      , total_ic_gb
      , smart_scan_gb
      , non_smart_scan_gb
    FROM
        precalc
),
--SELECT 
--    inst_id
--  , SUM(db_physio_gb)
--  , SUM(db_physrd_gb)
--  , SUM(db_physwr_gb)
--  , SUM(pred_offload_gb)
--  , SUM(phyrd_optim_gb)
--  , SUM(spin_disk_io_gb)
--  , SUM(spin_disk_rd_gb)
--  , SUM(spin_disk_io_gb - spin_disk_rd_gb) AS spin_disk_wr_gb
--  , SUM(scanned_uncomp_gb)
--  , ROUND(SUM((scanned_uncomp_gb/spin_disk_rd_gb)*db_physrd_gb)) AS est_full_uncomp_gb 
--  , SUM(total_ic_gb)
--  , SUM(smart_scan_gb)
--  , SUM(non_smart_scan_gb)
--FROM
--    precalc2
--GROUP BY ROLLUP
--    (inst_id)
--/
unpivoted AS (
    SELECT * FROM precalc2
    UNPIVOT (
            gb
        FOR metric
        IN (
            phyrd_optim_gb
          , phyrd_disk_and_flash_gb
          , phyrd_flash_rd_gb
          , scanned_uncomp_gb
          , est_full_uncomp_gb
          , non_smart_scan_gb
          , smart_scan_gb
          , total_ic_gb
          , pred_offload_gb
          , spin_disk_rd_gb
          , spin_disk_wr_gb
          , spin_disk_io_gb
          , db_physrd_gb 
          , db_physwr_gb
          , db_physio_gb
        )
    )
),
metric AS (
SELECT 'ADVANCED' type,       'AVOID_DISK_IO' category,  'PHYRD_OPTIM_GB'           name FROM dual UNION ALL
SELECT 'ADVANCED',            'AVOID_DISK_IO',           'PHYRD_DISK_AND_FLASH_GB'       FROM dual UNION ALL
SELECT 'ADVANCED',            'AVOID_DISK_IO',           'PHYRD_FLASH_RD_GB'             FROM dual UNION ALL        
SELECT 'ADVANCED',            'COMPRESS',                'SCANNED_UNCOMP_GB'             FROM dual UNION ALL
SELECT 'ADVANCED',            'COMPRESS',                'EST_FULL_UNCOMP_GB'            FROM dual UNION ALL
SELECT 'ADVANCED',            'REDUCE_INTERCONNECT',     'TOTAL_IC_GB'                   FROM dual UNION ALL
SELECT 'ADVANCED',            'REDUCE_INTERCONNECT',     'NON_SMART_SCAN_GB'             FROM dual UNION ALL
SELECT 'ADVANCED',            'REDUCE_INTERCONNECT',     'SMART_SCAN_GB'                 FROM dual UNION ALL
SELECT 'ADVANCED',            'REDUCE_INTERCONNECT',     'PRED_OFFLOAD_GB'               FROM dual UNION ALL
SELECT 'ADVANCED',            'DISK_IO',                 'SPIN_DISK_RD_GB'               FROM dual UNION ALL
SELECT 'ADVANCED',            'DISK_IO',                 'SPIN_DISK_WR_GB'               FROM dual UNION ALL
SELECT 'ADVANCED',            'DISK_IO',                 'SPIN_DISK_IO_GB'               FROM dual UNION ALL
SELECT 'ADVANCED',            'DISK_IO',                 'DB_PHYSRD_GB'                  FROM dual UNION ALL
SELECT 'ADVANCED',            'DISK_IO',                 'DB_PHYSWR_GB'                  FROM dual UNION ALL
SELECT 'ADVANCED',            'DISK_IO',                 'DB_PHYSIO_GB'                  FROM dual
)
SELECT
    inst_id
  , type
  , category
  , metric
  , '|'||RPAD(NVL(RPAD('#', ROUND(gb / (SELECT MAX(GB) FROM unpivoted) * 50 ), '#'), ' '), 50, ' ')||'|'     ioeff_percentage
  , gb
FROM
    unpivoted u
  , metric m
WHERE
    u.metric = m.name
/
