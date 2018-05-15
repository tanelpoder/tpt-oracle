-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

drop table qt_test;

create table qt_test (
    id      number        primary key
  , name    varchar2(100)
)
/

insert into qt_test select rownum, lpad('x',100,'x') from dual connect by level <=10000;

exec dbms_stats.gather_table_stats(user,'QT_TEST');

select count(name) from qt_test;
@x

alter table qt_test modify name not null;

select count(name) from qt_test;
@x

