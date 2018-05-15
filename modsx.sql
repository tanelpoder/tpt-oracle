-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL mods_owner              HEAD OWNER FOR A20
COL mods_table_name         HEAD TABLE_NAME FOR A30
COL mods_object_name        HEAD OBJECT_NAME FOR A30
COL mods_partition_name     HEAD PARTITION_NAME FOR A20
COL mods_subpartition_name  HEAD SUBPARTITION_NAME FOR A20

PROMPT Display table modifcations from DBA_TAB_MODIFICATIONS for tables &1....
SELECT
    t.owner       mods_owner
  , t.table_name  mods_table_name
  , m.partition_name mods_partition_name
  , m.subpartition_name mods_subpartition_name
  , m.inserts        inserts
  , m.updates        updates
  , m.deletes        deletes
  , m.inserts + m.updates + m.deletes total_dml
--  , t.num_rows
--  , ROUND(m.inserts + m.updates + m.deletes / NULLIF(t.num_rows,0) * 100, 1) changed_pct
FROM
    dba_tables t
  , dba_tab_modifications m
WHERE
    t.owner      = m.table_owner
AND t.table_name = m.table_name
AND upper(t.table_name) LIKE
        upper(CASE
          WHEN INSTR('&1','.') > 0 THEN
              SUBSTR('&1',INSTR('&1','.')+1)
          ELSE
              '&1'
          END
             )
AND owner LIKE
    CASE WHEN INSTR('&1','.') > 0 THEN
      UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
    ELSE
      user
    END
ORDER BY
    mods_owner
  , mods_table_name
  , partition_name
  , subpartition_name
/

