-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL cell_cell_path HEAD CELL_PATH FOR A20
COL cell_event     HEAD IO_TYPE   FOR A35
COL disk_name      HEAD DISK_NAME FOR A30
BREAK ON cell_event SKIP 1

--WITH cc AS (
--    SELECT /*+ MATERIALIZE */ 
--        CAST(extract(xmltype(confval), '/cli-output/cell/name/text()') AS VARCHAR2(20)) cell_name
--    FROM
--        v$cell_config
--    WHERE 
--)
SELECT /*+ CARDINALITY(a 100000) */ /* LEADING(c cc d) USE_HASH(d) USE_HASH(cc) USE_HASH(a) */
    a.event      cell_event
  , current_obj#
  , CAST(extract(xmltype(confval), '/cli-output/cell/name/text()') AS VARCHAR2(20)) cell_name
  , c.cell_path  cell_cell_path
--  , sql_id
  , nvl(substr(d.name,1,30),'-') disk_name
  --, substr(d.path,1,30) disk_path
  , c.cell_hashval
  , COUNT(*)
FROM
    v$cell c
  , v$cell_config cc
  , v$asm_disk d
  , v$active_session_history a
WHERE
    a.p1 = c.cell_hashval
AND c.cell_path = cc.cellname
--AND c.cell_path = replace(regexp_substr(d.path,'/(.*)/'),'/')
AND cc.conftype = 'CELL'
AND a.p2 = d.hash_value(+)
AND &1
--AND a.event LIKE 'cell%'
AND sample_time BETWEEN &2 AND &3
GROUP BY
    a.event
   , nvl(substr(d.name,1,30),'-') 
   --, substr(d.path,1,30)
   , CAST(extract(xmltype(confval), '/cli-output/cell/name/text()') AS VARCHAR2(20)) 
   , c.cell_path
   , c.cell_hashval
   , a.current_obj#
 --  , sql_id
--HAVING COUNT(*) > 1000
ORDER BY
    a.event 
  , COUNT(*) DESC
/


