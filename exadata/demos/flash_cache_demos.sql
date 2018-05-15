-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--CREATE BIGFILE TABLESPACE tanel_demo_auto   DATAFILE SIZE 100M AUTOEXTEND ON EXTENT MANAGEMENT LOCAL AUTOALLOCATE     SEGMENT SPACE MANAGEMENT AUTO;
--CREATE BIGFILE TABLESPACE tanel_demo_small  DATAFILE SIZE 100M AUTOEXTEND ON EXTENT MANAGEMENT LOCAL UNIFORM SIZE 64K SEGMENT SPACE MANAGEMENT AUTO;
--CREATE BIGFILE TABLESPACE tanel_demo_medium DATAFILE SIZE 100M AUTOEXTEND ON EXTENT MANAGEMENT LOCAL UNIFORM SIZE 8M  SEGMENT SPACE MANAGEMENT AUTO;
--CREATE BIGFILE TABLESPACE tanel_demo_large  DATAFILE SIZE 100M AUTOEXTEND ON EXTENT MANAGEMENT LOCAL UNIFORM SIZE 64M SEGMENT SPACE MANAGEMENT AUTO;

ALTER SESSION SET parallel_force_local = TRUE;

DROP TABLE t_fc_insert PURGE;
ALTER TABLESPACE tanel_demo_auto RESIZE 100M;

CREATE TABLE t_fc_insert TABLESPACE tanel_demo_auto STORAGE (CELL_FLASH_CACHE KEEP) AS 
SELECT * FROM tanel.sales
WHERE 1=0;

ALTER SESSION ENABLE PARALLEL DML; -- otherwise the INSERT part will be serial, done by QC

VAR snapper       REFCURSOR
VAR begin_snap_id NUMBER
VAR end_snap_id   NUMBER

EXEC :begin_snap_id := exasnap.begin_snap;
@snapper4 all,begin 1 1 &mysid
INSERT /*+ APPEND MONITOR PARALLEL(8) */ INTO t_fc_insert SELECT * FROM tanel.sales;
COMMIT;
@snapper4 all,end   1 1 &mysid
EXEC :end_snap_id := exasnap.end_snap;

@xp &mysid
SELECT * FROM TABLE(exasnap.display_snap(:begin_snap_id, :end_snap_id, '%'));



-- different caching options
DROP TABLE t_cached PURGE;
DROP TABLE t_default_cached PURGE;
DROP TABLE t_not_cached PURGE;
DROP TABLE t_small_extents;

CREATE TABLE t_cached         NOPARALLEL TABLESPACE tanel_demo_auto  STORAGE (cell_flash_cache KEEP)    AS SELECT * FROM sales;
CREATE TABLE t_default_cached NOPARALLEL TABLESPACE tanel_demo_auto  STORAGE (cell_flash_cache DEFAULT) AS SELECT * FROM sales;
CREATE TABLE t_not_cached     PARALLEL 16 TABLESPACE tanel_demo_auto  STORAGE (cell_flash_cache NONE)    AS SELECT * FROM sales;

CREATE TABLE t_small_extents  PARALLEL 16 TABLESPACE tanel_demo_small STORAGE (CELL_FLASH_CACHE DEFAULT) AS SELECT * FROM sales;



-- cell commands
-- iostat -xm 5 | egrep -v "sd.[0-9]|^md"
-- lsscsi

-- DESCRIBE FLASHCACHECONTENT
-- cachedKeepSize
-- cachedSize
-- dbID
-- dbUniqueName
-- hitCount
-- hoursToExpiration
-- missCount
-- objectNumber
-- tableSpaceNumber

-- LIST FLASHCACHECONTENT ATTRIBUTES ALL;
-- dcli -l root -g ~/x2cells "cellcli -e 'LIST FLASHCACHECONTENT ATTRIBUTES cachedKeepSize,cachedSize,dbID,dbUniqueName,hitCount,missCount,objectNumber,tableSpaceNumber'" | sed 's/:/       /' > fc.xls

--   cachedKeepSize:       0
--   cachedSize:           1048576
--   dbID:                 1538629110
--   dbUniqueName:         DEMO
--   hitCount:             103840
--   missCount:            4
--   objectNumber:         4294967294
--   tableSpaceNumber:     0

