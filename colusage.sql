-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show column usage stats from sys.col_usage$ for table &1..&2....
prompt Did you run DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO for getting latest stats?


select
    c.owner
  , c.table_name
  , c.column_name
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
and lower(o.owner) like lower('&1')
and lower(o.object_name) like lower('&2')
order by
    owner
  , table_name
  , column_name
/
