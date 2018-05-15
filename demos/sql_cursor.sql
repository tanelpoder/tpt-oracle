-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set echo on

select curno,status,pers_heap_mem,work_heap_mem from v$sql_cursor where status != 'CURNULL';
pause

var x refcursor
exec open :x for select * from all_objects order by dbms_random.random;
pause

declare r all_objects%rowtype; begin fetch :x into r; end;
/

pause

select curno,status,pers_heap_mem,work_heap_mem from v$sql_cursor where status != 'CURNULL';

set echo off
