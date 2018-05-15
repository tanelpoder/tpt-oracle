-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

drop table t;

create table t as 
select rownum a, 'zzz' b from dual connect by level<=1000
union all
select 0, 'yyy' FROM dual;

create index i on t(a);

exec dbms_stats.gather_table_stats(user,'T',method_opt=>'FOR COLUMNS A,B SIZE 254');

alter session set cursor_sharing = similar;

declare
    j number;
begin
    for i in 1..1000 loop
         select count(*) into j from t where a = to_char(i);
    end loop;
end;
/ 


