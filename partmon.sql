-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- whenever sqlerror exit 1 rollback
-- whenever oserror exit 2 rollback

set linesize 250 trimspool on serverout on size 1000000 feedback off verify off tab off

declare
   l long;
   dmax date;
   dbname varchar2(30);
   hostname varchar2(255);
   generate_droplist number(1,0):=0;
   days number(10,0);
begin

   select name into dbname from v$database;
   select host_name into hostname from v$instance;

   dbms_output.put_line(chr(0));
   dbms_output.put_line('- REPORT FOR DBNAME: '|| dbname ||' @ '|| hostname|| ' STARTED: ' || to_char(sysdate, 'YYYYMMDD HH24:MI:SS') );
   dbms_output.put_line(chr(0));

   dbms_output.put_line('- BUFFER TIME: VALUES UP TO FOLLOWING DATES ALLOWED IN NEWEST PARTITIONS:');
   dbms_output.put_line('-----------------------------------------------------------------------------------------------');
   dbms_output.put_line(rpad('- PARTITION ', 65, ' ') ||'|'||' DAYS '||'| PARTITION HIGH VALUE');
   dbms_output.put_line('-----------------------------------------------------------------------------------------------');

   for c in (    select p.table_owner, p.table_name, p.partition_name, p.high_value
                 from dba_tab_partitions p
                 where partition_position =    (
                                select max(partition_position)
                                from dba_tab_partitions
                                where table_name = p.table_name
                                and   table_owner = p.table_owner
                            )
                 and table_owner not in ('SYS','SYSTEM')
                 order by p.table_owner, p.table_name
            )
   loop
       execute immediate 'select '||c.high_value||' from dual' into dmax;
       days:=trunc(dmax-sysdate);

       -- Print output, snap DATE out of long HIGH_VALUE string

       dbms_output.put_line(rpad(c.table_owner||'.'||c.table_name||':'||c.partition_name,65,' ') ||' '|| lpad(to_char(days),5,' ') ||'   '||
                            substr(   c.high_value,instr(c.high_value,' ')+1, instr( substr(c.high_value,instr(c.high_value,' ')+1),''',')-1 )   );

       if days > &1 then generate_droplist:=1; end if;
   end loop;

   dbms_output.put_line(chr(0));
   dbms_output.put_line('- HISTORY: VALUES UP TO FOLLOWING DATES IN OLDEST PARTITIONS:');
   dbms_output.put_line('-----------------------------------------------------------------------------------------------');
   dbms_output.put_line(rpad('- PARTITION ', 65, ' ') ||'|'||' DAYS '||'| PARTITION HIGH VALUE');
   dbms_output.put_line('-----------------------------------------------------------------------------------------------');

   for c in (    select p.table_owner, p.table_name, p.partition_name, p.high_value
                 from dba_tab_partitions p
                 where partition_position =    (
                                select min(partition_position)
                                from dba_tab_partitions
                                where table_name = p.table_name
                                and   table_owner = p.table_owner
                            )
                 and table_owner not in ('SYS','SYSTEM')
                 order by p.table_owner, p.table_name
            )
   loop
       execute immediate 'select '||c.high_value||' from dual' into dmax;
       days:=trunc(sysdate-dmax);

       -- Print output, snap DATE out of long HIGH_VALUE string

       dbms_output.put_line(rpad(c.table_owner||'.'||c.table_name||':'||c.partition_name,65,' ') ||' '|| lpad(to_char(days),5,' ') ||'   '||
                            substr(   c.high_value,instr(c.high_value,' ')+1, instr( substr(c.high_value,instr(c.high_value,' ')+1),''',')-1 )   );

       if days > &1 then generate_droplist:=1; end if;

   end loop;

   if generate_droplist <> 0 then
       dbms_output.put_line(chr(0));
       dbms_output.put_line('- SOME PARTITIONS ARE OLDER THAN '||&1||' DAYS - GENERATING DROP COMMANDS');
       dbms_output.put_line('-----------------------------------------------------------------------------------------------');
       dbms_output.put_line('- PARTITION DROP COMMANDS - REVIEW CAREFULLY');
       dbms_output.put_line('-----------------------------------------------------------------------------------------------');
       dbms_output.put_line(chr(0));

       dbms_output.put_line('whenever sqlerror exit 1 rollback');
       dbms_output.put_line('whenever sqlerror exit 1 rollback');
       dbms_output.put_line('set echo on');
       dbms_output.put_line(chr(0));

       for c in (    select p.table_owner, p.table_name, p.partition_name, p.high_value
                     from dba_tab_partitions p
                     where partition_position =    (
                                    select min(partition_position)
                                    from dba_tab_partitions
                                    where table_name = p.table_name
                                    and   table_owner = p.table_owner
                                )
                     and table_owner not in ('SYS','SYSTEM')
                     order by p.table_owner, p.table_name
                )
       loop
           execute immediate 'select '||c.high_value||' from dual' into dmax;
           days:=trunc(sysdate-dmax);

           -- Print output, snap DATE out of long HIGH_VALUE string
           if days > &1 then
           -- dbms_output.put_line('prompt ALTER TABLE '|| c.table_owner||'.'||c.table_name||' DROP PARTITION '||c.partition_name||'; -- '||days||' DAYS OLD');
           dbms_output.put_line('ALTER TABLE '|| c.table_owner||'.'||c.table_name||' DROP PARTITION '||c.partition_name||';');
           end if;

       end loop;

       dbms_output.put_line(chr(0));
       dbms_output.put_line('exit');
       dbms_output.put_line(chr(0));

   end if;

   dbms_output.put_line(chr(0));
   dbms_output.put_line('- REPORT FOR DBNAME: '|| dbname ||' @ '|| hostname|| ' COMPLETED: ' || to_char(sysdate, 'YYYYMMDD HH24:MI:SS') );
   dbms_output.put_line(chr(0));

end;
/

set feedback on