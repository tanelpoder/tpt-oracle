-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   demos/fetch.sql "<SQL to execute>"
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--
--              Shows effect of arraysize to fetch lengths and 
--              in which execution/fetching stage data access work is done              
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
--
-- Copyright:   (c) 2007-2009 Tanel Poder
--
--------------------------------------------------------------------------------

set termout off

drop table t;

create table t as 
select 
   rownum a
 , CAST(rownum as CHAR(2000)) b 
from 
   dual 
connect by 
   level <= 50
/

create index i on t(a);

exec dbms_stats.gather_table_stats(user, 'T');

--set arraysize 5

col fetch_command new_value fetch_command

select replace(replace(replace('&1', '*', '\*'),'/','\/'),'>','\>') fetch_command from dual; 

-- hard parse
clear buffer
1 &1
/

alter session set sql_trace=true;

@ti
set termout off

clear buffer
1 &1
/

set termout on

prompt TRACE OUTPUT:
prompt _________________________________
prompt

host "grep -A 99999 -B1 '&fetch_command' &trc | sed -e '/&fetch_command/p;/PARS/p;/EXEC/p;/FETCH/p;d'"

--select * from table(dbms_xplan.display_cursor(null,null, 'ALLSTATS LAST'));

