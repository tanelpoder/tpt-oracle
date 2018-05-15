-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

drop table t;

create table t as 
select rownum a, 'zzz' b from dual connect by level<=1000;

create index i on t(a);

exec dbms_stats.gather_table_stats(user,'T',method_opt=>'FOR COLUMNS A SIZE 254');

@sqlt "select * from t where a ="


alter session set cursor_sharing = similar;

spool lotsofselects.sql

select 'select * from t where a = '||rownum||';' from dual connect by level<=10000;

spool off

@lotsofselects.sql
@hash


@sqlt "select * from t where a ="

--exec for i in 1 .. 10000 loop execute immediate 'delete t where a = '||to_char(i); end loop;
--declare j number; begin for i in 1..1000 loop select count(*) into  


