-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

------------------------------------------------------------------------------------------------------------------------
--
-- File name:   cellpd.sql (v1.0)
--
-- Purpose:     Report physical disk summary from V$CELL_CONFIG
--
-- Author:      Tanel Poder (tanel@tanelpoder.com)
--
-- Copyright:   (c) http://blog.tanelpoder.com - All rights reserved.
--
-- Disclaimer:  This script is provided "as is", no warranties nor guarantees are
--              made. Use at your own risk :)
--              
-- Usage:       @cellpd.sql
--
------------------------------------------------------------------------------------------------------------------------

COL cv_cellname       HEAD CELLNAME         FOR A20
COL cv_cellversion    HEAD CELLSRV_VERSION  FOR A20
COL cv_flashcachemode HEAD FLASH_CACHE_MODE FOR A20

PROMPT Show Exadata cell versions from V$CELL_CONFIG....

SELECT 
    disktype
  , cv_cellname
  , status
  , ROUND(SUM(physicalsize/1024/1024/1024)) total_gb
  , ROUND(AVG(physicalsize/1024/1024/1024)) avg_gb
  , COUNT(*) num_disks
  , SUM(CASE WHEN predfailStatus  = 'TRUE' THEN 1 END) predfail
  , SUM(CASE WHEN poorPerfStatus  = 'TRUE' THEN 1 END) poorperf
  , SUM(CASE WHEN wtCachingStatus = 'TRUE' THEN 1 END) wtcacheprob
  , SUM(CASE WHEN peerFailStatus  = 'TRUE' THEN 1 END) peerfail
  , SUM(CASE WHEN criticalStatus  = 'TRUE' THEN 1 END) critical
FROM (
    SELECT /*+ NO_MERGE */
        c.cellname cv_cellname
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/name/text()')                          AS VARCHAR2(20)) diskname
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/diskType/text()')                      AS VARCHAR2(20)) diskType          
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/luns/text()')                          AS VARCHAR2(20)) luns              
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/makeModel/text()')                     AS VARCHAR2(50)) makeModel         
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalFirmware/text()')              AS VARCHAR2(20)) physicalFirmware  
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalInsertTime/text()')            AS VARCHAR2(30)) physicalInsertTime
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalSerial/text()')                AS VARCHAR2(20)) physicalSerial    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalSize/text()')                  AS VARCHAR2(20)) physicalSize      
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/slotNumber/text()')                    AS VARCHAR2(30)) slotNumber        
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/status/text()')                        AS VARCHAR2(20)) status            
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/id/text()')                            AS VARCHAR2(20)) id                
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/key_500/text()')                       AS VARCHAR2(20)) key_500           
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/predfailStatus/text()')                AS VARCHAR2(20)) predfailStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/poorPerfStatus/text()')                AS VARCHAR2(20)) poorPerfStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/wtCachingStatus/text()')               AS VARCHAR2(20)) wtCachingStatus   
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/peerFailStatus/text()')                AS VARCHAR2(20)) peerFailStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/criticalStatus/text()')                AS VARCHAR2(20)) criticalStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errCmdTimeoutCount/text()')            AS VARCHAR2(20)) errCmdTimeoutCount
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errHardReadCount/text()')              AS VARCHAR2(20)) errHardReadCount  
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errHardWriteCount/text()')             AS VARCHAR2(20)) errHardWriteCount 
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errMediaCount/text()')                 AS VARCHAR2(20)) errMediaCount     
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errOtherCount/text()')                 AS VARCHAR2(20)) errOtherCount     
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errSeekCount/text()')                  AS VARCHAR2(20)) errSeekCount      
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/sectorRemapCount/text()')              AS VARCHAR2(20)) sectorRemapCount  
    FROM
        v$cell_config c
      , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.confval), '/cli-output/physicaldisk'))) v  -- gv$ isn't needed, all cells should be visible in all instances
    WHERE 
        c.conftype = 'PHYSICALDISKS'
)
GROUP BY
    cv_cellname
  , disktype
  , status
ORDER BY
    disktype
  , cv_cellname
/

