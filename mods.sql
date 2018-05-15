-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL mods_owner FOR A30
COL mods_table_name FOR A30
COL mods_object_name FOR A30

PROMPT Display table modifcations from DBA_TAB_MODIFICATIONS for tables &1....
SELECT
    t.owner       mods_owner
  , t.table_name  mods_table_name
  , SUM(m.inserts      )  inserts
  , SUM(m.updates      )  updates
  , SUM(m.deletes      )  deletes
  , SUM(m.inserts) + SUM(m.updates) + SUM(m.deletes) total_dml
  , t.num_rows
  , ROUND((SUM(m.inserts) + SUM(m.updates) + SUM(m.deletes)) / NULLIF(t.num_rows,0) * 100, 1) changed_pct
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
GROUP BY
    t.owner       -- mods_owner
  , t.table_name  -- mods_object_name
  , t.num_rows
ORDER BY
    mods_owner
  , mods_table_name
/

