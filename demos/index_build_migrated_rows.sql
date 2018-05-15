-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

drop table t;

create table t PCTFREE 0 as select * from dba_source, (select 1 from dual connect by level<=5);
--create table t PCTFREE 0 as select * from dba_source;

-- deliberately using analyze table command to compute the number of chained rows
analyze table t compute statistics;
select num_rows,blocks,empty_blocks,chain_cnt from user_tables where table_name = 'T';

update t set owner = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' where rownum <= 100000;
commit;

update t set owner = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' where rownum <= 100000;
commit;

update t set owner = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' where rownum <= 100000;
commit;

update t set owner = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' where rownum <= 100000;
commit;

update t set owner = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' where rownum <= 100000;
commit;

update t set owner = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' where rownum <= 100000;
commit;

analyze table t compute statistics;
select num_rows,blocks,empty_blocks,chain_cnt from user_tables where table_name = 'T';

--exec dbms_stats.gather_table_stats(user,'T');

pause About to create the index, run snapper in another window on this session. Press ENTER to continue...

create index i on t(case when owner = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' then owner else null end) online;


