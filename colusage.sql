-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col colusage_owner      head OWNER for a25 wrap
col colusage_table_name head TABLE_NAME for a25 wrap
col colusage_column_name head COLUMN_NAME for a25 wrap

prompt Show column usage stats from sys.col_usage$ for table &1..&2....
prompt Did you run DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO for getting latest stats?

select
    c.owner            colusage_owner
  , c.table_name       colusage_table_name
  , c.column_name      colusage_column_name
  , u.intcol#
  , u.equality_preds       
  , u.equijoin_preds       
  , u.nonequijoin_preds    
  , u.range_preds          
  , u.like_preds           
  , u.null_preds           
  , u.timestamp           
from
    sys.col_usage$ u
  , dba_objects    o
  , dba_tab_cols   c
where
    o.object_id  = u.obj#
and c.owner      = o.owner
and c.table_name = o.object_name
and u.intcol#    = c.internal_column_id
and o.object_type = 'TABLE'
and  upper(o.object_name) like
        upper(case
          when instr('&1','.') > 0 then
              substr('&1',instr('&1','.')+1)
          else
              '&1'
          end
             )
and o.owner like
    case when instr('&1','.') > 0 then
      upper(substr('&1',1,instr('&1','.')-1))
    else
      user
    end
order by
    o.owner
  , c.table_name
  , c.column_name
/
