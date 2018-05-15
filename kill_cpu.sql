-- prompt Jonathan Lewis'es kill_cpu script
--
-- create the kill_cpu table first:
--   create table kill_cpu(n primary key) organization index as select rownum from all_objects where rownum <=50;

-- this is required in 10g+ to get the "kill_cpu effect"
-- however in 10.2 this occasionally ends up crashing your session
-- so this is for hacking environments only

alter session set "_old_connect_by_enabled"=true;

select /*+ monitor */ count(*) X 
from kill_cpu 
connect by n > prior n 
start with n = 1 
/
