-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   grpn.sql
-- Purpose:     Quick group by query for aggregating Numeric columns
--              Calculate sum,min,max,avg,count for simple expressions
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @grpn <agg_col> <from_table> <filter_cond> <group_by_cols>
--              @grpn bytes dba_segments tablespace_name='SYSTEM' owner,segment_type
-- 	        
--	        
--------------------------------------------------------------------------------


select 
    &4,
    count(&1),
    count(distinct &1) DISTCNT,
    sum(&1),
    avg(&1),
    min(&1),
    max(&1)
from
    &2
where
    &3
group by --rollup
    ( &4 )
/

