-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set echo on

drop table t;

create table t(a int, b char(100));

insert /*+ APPEND */ into t select rownum, object_name from all_objects;

create &1 index i on t(a);

exec dbms_stats.gather_table_stats(user,'T');

-- hard parse statement
set termout off
select a from t where a = 40000; 
set termout on

set autot trace stat

select a from t where a = 40000; 

set echo off autot off