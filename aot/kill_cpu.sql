-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt
prompt Jonathan Lewis'es kill_cpu script
prompt

set termout off

--drop table kill_cpu;

create table kill_cpu (n, primary key(n)) organization index 
as 
select rownum n 
from all_objects 
where rownum <= 50
; 

set termout on echo on

alter session set "_old_connect_by_enabled"=true;

select count(*) X 
from kill_cpu 
connect by n > prior n 
start with n = 1 
; 

set echo off
