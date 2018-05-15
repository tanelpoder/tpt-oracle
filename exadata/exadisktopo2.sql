-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

------------------------------------------------------------------------------------------------------------------------
--
-- File name:   exadisktopo2.sql (v1.0)
--
-- Purpose:     Report Exadata disk topology from cell LUNs and Physical disks all the way to ASM diskgroups
--              (from bottom of the IO stack upwards)
--
-- Author:      Tanel Poder (tanel@tanelpoder.com)
--
-- Copyright:   Tanel Poder (c) http://blog.tanelpoder.com - All rights reserved.
--
-- Disclaimer:  This script is provided "as is", no warranties nor guarantees are
--              made. Use at your own risk :)
--              
-- Usage:       @exadatadisktopo2
--
------------------------------------------------------------------------------------------------------------------------

COL cellname            HEAD CELLNAME       FOR A20
COL celldisk_name       HEAD CELLDISK       FOR A30
COL physdisk_name       HEAD PHYSDISK       FOR A30
COL griddisk_name       HEAD GRIDDISK       FOR A30
COL asmdisk_name        HEAD ASMDISK        FOR A30

BREAK ON cellname SKIP 1

PROMPT Showing Exadata disk topology from V$ASM_DISK and V$CELL_CONFIG....

WITH
  pd AS (
    SELECT /*+ MATERIALIZE */
        c.cellname
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/name/text()')                          AS VARCHAR2(100)) name
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/diskType/text()')                      AS VARCHAR2(100)) diskType          
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/luns/text()')                          AS VARCHAR2(100)) luns              
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/makeModel/text()')                     AS VARCHAR2(100)) makeModel         
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalFirmware/text()')              AS VARCHAR2(100)) physicalFirmware  
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalInsertTime/text()')            AS VARCHAR2(100)) physicalInsertTime
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalSerial/text()')                AS VARCHAR2(100)) physicalSerial    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/physicalSize/text()')                  AS VARCHAR2(100)) physicalSize      
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/slotNumber/text()')                    AS VARCHAR2(100)) slotNumber        
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/status/text()')                        AS VARCHAR2(100)) status            
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/id/text()')                            AS VARCHAR2(100)) id                
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/key_500/text()')                       AS VARCHAR2(100)) key_500           
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/predfailStatus/text()')                AS VARCHAR2(100)) predfailStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/poorPerfStatus/text()')                AS VARCHAR2(100)) poorPerfStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/wtCachingStatus/text()')               AS VARCHAR2(100)) wtCachingStatus   
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/peerFailStatus/text()')                AS VARCHAR2(100)) peerFailStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/criticalStatus/text()')                AS VARCHAR2(100)) criticalStatus    
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errCmdTimeoutCount/text()')            AS VARCHAR2(100)) errCmdTimeoutCount
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errHardReadCount/text()')              AS VARCHAR2(100)) errHardReadCount  
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errHardWriteCount/text()')             AS VARCHAR2(100)) errHardWriteCount 
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errMediaCount/text()')                 AS VARCHAR2(100)) errMediaCount     
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errOtherCount/text()')                 AS VARCHAR2(100)) errOtherCount     
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/errSeekCount/text()')                  AS VARCHAR2(100)) errSeekCount      
      , CAST(EXTRACTVALUE(VALUE(v), '/physicaldisk/sectorRemapCount/text()')              AS VARCHAR2(100)) sectorRemapCount  
    FROM
        v$cell_config c
      , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.confval), '/cli-output/physicaldisk'))) v  -- gv$ isn't needed, all cells should be visible in all instances
    WHERE 
        c.conftype = 'PHYSICALDISKS'
),
 cd AS (
    SELECT /*+ MATERIALIZE */
        c.cellname 
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/name/text()')                              AS VARCHAR2(100)) name
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/comment        /text()')                   AS VARCHAR2(100)) disk_comment
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/creationTime   /text()')                   AS VARCHAR2(100)) creationTime
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/deviceName     /text()')                   AS VARCHAR2(100)) deviceName
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/devicePartition/text()')                   AS VARCHAR2(100)) devicePartition
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/diskType       /text()')                   AS VARCHAR2(100)) diskType
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/errorCount     /text()')                   AS VARCHAR2(100)) errorCount
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/freeSpace      /text()')                   AS VARCHAR2(100)) freeSpace
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/id             /text()')                   AS VARCHAR2(100)) id
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/interleaving   /text()')                   AS VARCHAR2(100)) interleaving
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/lun            /text()')                   AS VARCHAR2(100)) lun
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/physicalDisk   /text()')                   AS VARCHAR2(100)) physicalDisk
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/size           /text()')                   AS VARCHAR2(100)) disk_size
      , CAST(EXTRACTVALUE(VALUE(v), '/celldisk/status         /text()')                   AS VARCHAR2(100)) status
    FROM
        v$cell_config c
      , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.confval), '/cli-output/celldisk'))) v  -- gv$ isn't needed, all cells should be visible in all instances
    WHERE 
        c.conftype = 'CELLDISKS'
),
 gd AS (
    SELECT /*+ MATERIALIZE */
        c.cellname 
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/name/text()')                               AS VARCHAR2(100)) name
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/asmDiskgroupName/text()')                   AS VARCHAR2(100)) asmDiskgroupName 
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/asmDiskName     /text()')                   AS VARCHAR2(100)) asmDiskName
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/asmFailGroupName/text()')                   AS VARCHAR2(100)) asmFailGroupName
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/availableTo     /text()')                   AS VARCHAR2(100)) availableTo
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/cachingPolicy   /text()')                   AS VARCHAR2(100)) cachingPolicy
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/cellDisk        /text()')                   AS VARCHAR2(100)) cellDisk
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/comment         /text()')                   AS VARCHAR2(100)) disk_comment
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/creationTime    /text()')                   AS VARCHAR2(100)) creationTime
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/diskType        /text()')                   AS VARCHAR2(100)) diskType
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/errorCount      /text()')                   AS VARCHAR2(100)) errorCount
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/id              /text()')                   AS VARCHAR2(100)) id
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/offset          /text()')                   AS VARCHAR2(100)) offset
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/size            /text()')                   AS VARCHAR2(100)) disk_size
      , CAST(EXTRACTVALUE(VALUE(v), '/griddisk/status          /text()')                   AS VARCHAR2(100)) status
    FROM
        v$cell_config c
      , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.confval), '/cli-output/griddisk'))) v  -- gv$ isn't needed, all cells should be visible in all instances
    WHERE 
        c.conftype = 'GRIDDISKS'
),
 lun AS (
    SELECT /*+ MATERIALIZE */
        c.cellname 
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/cellDisk         /text()')              AS VARCHAR2(100)) cellDisk      
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/deviceName       /text()')              AS VARCHAR2(100)) deviceName    
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/diskType         /text()')              AS VARCHAR2(100)) diskType      
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/id               /text()')              AS VARCHAR2(100)) id            
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/isSystemLun      /text()')              AS VARCHAR2(100)) isSystemLun   
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/lunAutoCreate    /text()')              AS VARCHAR2(100)) lunAutoCreate 
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/lunSize          /text()')              AS VARCHAR2(100)) lunSize       
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/physicalDrives   /text()')              AS VARCHAR2(100)) physicalDrives
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/raidLevel        /text()')              AS VARCHAR2(100)) raidLevel
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/lunWriteCacheMode/text()')              AS VARCHAR2(100)) lunWriteCacheMode
      , CAST(EXTRACTVALUE(VALUE(v), '/lun/status           /text()')              AS VARCHAR2(100)) status        
    FROM
        v$cell_config c
      , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.confval), '/cli-output/lun'))) v  -- gv$ isn't needed, all cells should be visible in all instances
    WHERE 
        c.conftype = 'LUNS'
)
 , ad  AS (SELECT /*+ MATERIALIZE */ * FROM v$asm_disk)
 , adg AS (SELECT /*+ MATERIALIZE */ * FROM v$asm_diskgroup)
SELECT 
    pd.cellname
  , SUBSTR(lun.deviceName,1,20)     lun_devicename
  , pd.name physdisk_name
  , SUBSTR(pd.status,1,20)          physdisk_status
  , cd.name celldisk_name
  , SUBSTR(cd.devicepartition,1,20) cd_devicepart
  , gd.name griddisk_name
  , ad.name  asm_disk
  , adg.name asm_diskgroup
  , lun.lunWriteCacheMode
--  , SUBSTR(cd.devicename,1,20)      cd_devicename
--  , SUBSTR(lun.devicename,1,20)     lun_devicename
FROM
    gd
  , cd
  , pd
  , lun
  , ad
  , adg
WHERE
    ad.group_number = adg.group_number (+)
AND gd.asmdiskname = ad.name (+)
AND cd.name = gd.cellDisk (+)
AND pd.id =   cd.physicalDisk (+)
AND cd.name = lun.celldisk (+)
ORDER BY
    --disktype
    cellname
  , celldisk_name
  , griddisk_name
  , asm_disk
  , asm_diskgroup
/

CLEAR BREAKS

