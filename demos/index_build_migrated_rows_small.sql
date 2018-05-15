-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

drop table t;

create table t PCTFREE 0 as select * from all_objects;

update t set owner = lpad('x',30,'x') where owner = 'SYS' and rownum <= 10;

analyze table t compute statistics;

select chain_cnt from user_tables where table_name = 'T';

create index i on t(owner);

