-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

desc sydney_demo1
desc sydney_demo2
desc sydney_demo3

alter session set plsql_optimize_level=0;

set timing on
exec for i in 1..&1 loop insert into sydney_demo1 values (0); end loop;

set timing off termout off
rollback;
alter system checkpoint;
set timing on  termout on

exec for i in 1..&1 loop insert into sydney_demo2 values (0); end loop;

set timing off termout off
rollback;
alter system checkpoint;
set timing on  termout on

exec for i in 1..&1 loop insert into sydney_demo3 values (0); end loop;

set timing off termout off
rollback;
alter system checkpoint;
set timing on  termout on

set timing off

























--create table sydney_demo1 (a int) tablespace system;
--create table sydney_demo2 (a int) tablespace users;
--create table sydney_demo3 (a int) tablespace users2;
