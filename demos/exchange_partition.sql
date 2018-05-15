-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--drop table mytab;
--drop table tmp;

-- this is our "source table"
create table mytab as select * from all_objects;
create index i on mytab(owner);

-- this is where we copy only needed rows:
create table tmp 
partition by range (owner) (
  partition p1 values less than (maxvalue)
)
as
select * from mytab 
where owner != 'SYS'
/

-- in order to do partition exchange, the physical structure of source table and target need to be the same (including indexes):
create index i_tmp on tmp(owner) local;

-- get rid of old rows
truncate table mytab;

-- exchange the tmp.p1 partition segment with mytab's segment
alter table tmp exchange partition p1 with table mytab including indexes;

-- you may need to run this to validate any constraints if they're in novalidate status
alter table mytab constraint <constraint_name> enable validate;
