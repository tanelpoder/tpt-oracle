-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

------------------------------------------------------------------------------------------------------------------------
--
-- File name:   celliorm.sql (v1.0)
--
-- Purpose:     Report Exadata cell IORM status from V$CELL_CONFIG
--
-- Author:      Tanel Poder
--
-- Copyright:   (c) http://blog.tanelpoder.com - All rights reserved.
--
-- Disclaimer:  This script is provided "as is", no warranties nor guarantees are
--              made. Use at your own risk :)
--              
-- Usage:       @celliorm.sql
--
------------------------------------------------------------------------------------------------------------------------

COL cv_cellname       HEAD CELLNAME         FOR A20
COL cv_cellversion    HEAD CELLSRV_VERSION  FOR A20
COL cv_flashcachemode HEAD FLASH_CACHE_MODE FOR A20

PROMPT Show Exadata cell versions from V$CELL_CONFIG....

SELECT
    cellname cv_cellname
  , CAST(extract(xmltype(confval), '/cli-output/interdatabaseplan/objective/text()') AS VARCHAR2(20)) objective
  , CAST(extract(xmltype(confval), '/cli-output/interdatabaseplan/status/text()')    AS VARCHAR2(15)) status
  , CAST(extract(xmltype(confval), '/cli-output/interdatabaseplan/name/text()')      AS VARCHAR2(30)) interdb_plan
  , CAST(extract(xmltype(confval), '/cli-output/interdatabaseplan/catPlan/text()')   AS VARCHAR2(30)) cat_plan
  , CAST(extract(xmltype(confval), '/cli-output/interdatabaseplan/dbPlan/text()')    AS VARCHAR2(30)) db_plan
FROM 
    v$cell_config  -- gv$ isn't needed, all cells should be visible in all instances
WHERE 
    conftype = 'IORM'
ORDER BY
    cv_cellname
/

