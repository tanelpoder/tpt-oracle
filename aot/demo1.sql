-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   demo1.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--              Depending on the speed of LGWR IO will cause the session to wait
--              for log buffer space and log switch wait events (demo works
--              ok on a single hard disk laptop, probably will not wait so much
--              on a server with write cached storage)
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
-- Copyright:   (c) Tanel Poder
--
--------------------------------------------------------------------------------

prompt Initializing Demo1...

set feedback off termout off

drop table t;
drop table t2;

create table t tablespace users as select * from dba_source;
create table t2 tablespace users as select * from dba_source where 1=0;

alter system switch logfile;
alter system switch logfile;

set termout on
--prompt Taking Statspack report...
--EXEC statspack.snap

prompt Starting Demo1 (running a "batch job")
set termout off

insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;

commit;

insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;

commit;

insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;
insert into t2 select * from t;

commit;


set termout on

prompt "Batch job" finished...
--prompt Taking Statspack report...
--EXEC statspack.snap


