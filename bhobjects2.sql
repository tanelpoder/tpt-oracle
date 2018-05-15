-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINES 999 PAGES 5000 TRIMSPOOL ON TRIMOUT ON

col bhobjects_owner head OWNER for a30
col bhobjects_object_name head OBJECT_NAME for a30
col bhobjects_subobject_name head SUBOBJECT_NAME for a30
col bhobjects_object_type head OBJECT_TYPE for a20 word_wrap

select * from v$sgainfo;
select * from v$sga_dynamic_components;
select * from v$buffer_pool;

SELECT * FROM (
    SELECT
        TO_CHAR(ROUND(RATIO_TO_REPORT( ROUND(SUM(ts.block_size) / 1048576) ) OVER () * 100, 1), '999.9')||' %'  "%BUFCACHE"
      , ROUND(SUM(ts.block_size) / 1048576) MB
      --, count(*) buffers
      , bh.objd                dataobj_id
      , ts.tablespace_name
      , o.owner                bhobjects_owner
      , o.object_name          bhobjects_object_name
      , o.subobject_name       bhobjects_subobject_name
      , o.object_type          bhobjects_object_type
    FROM
        v$bh bh
      , (SELECT data_object_id
              , MIN(owner) owner
              , MIN(object_name) object_name
              , MIN(subobject_name) subobject_name
              , MIN(object_type) object_type
              , COUNT(*) num_duplicates 
        FROM dba_objects GROUP BY data_object_id) o
      , v$tablespace vts
      , dba_tablespaces ts
    WHERE 
        bh.objd = o.data_object_id (+)
    AND bh.ts#  = vts.ts#
    AND vts.name = ts.tablespace_name
    GROUP BY
        bh.objd, ts.tablespace_name, o.owner, o.object_name, o.subobject_name, o.object_type
    ORDER BY 
        mb DESC
)
WHERE ROWNUM <=30
/

SELECT * FROM (
    SELECT
        TO_CHAR(ROUND(RATIO_TO_REPORT( ROUND(SUM(ts.block_size) / 1048576) ) OVER () * 100, 1), '999.9')||' %'  "%BUFCACHE"
      , ROUND(SUM(ts.block_size) / 1048576) MB
      , ts.tablespace_name
      , bh.status
    FROM
        v$bh bh
      , (SELECT data_object_id
              , MIN(owner) owner
              , MIN(object_name) object_name
              , MIN(subobject_name) subobject_name
              , MIN(object_type) object_type
              , COUNT(*) num_duplicates 
        FROM dba_objects GROUP BY data_object_id) o
      , v$tablespace vts
      , dba_tablespaces ts
    WHERE 
        bh.objd = o.data_object_id (+)
    AND bh.ts#  = vts.ts#
    AND vts.name = ts.tablespace_name
    GROUP BY
        ts.tablespace_name
      , bh.status
    ORDER BY 
        mb DESC
)
WHERE ROWNUM <=30
/

