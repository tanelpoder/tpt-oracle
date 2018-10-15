-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

@@saveset

column _ti_sequence noprint new_value _ti_sequence

set feedback off heading off

select trim(to_char( &_ti_sequence + 1 , '0999' )) "_ti_sequence" from dual;

alter session set tracefile_identifier="&_ti_sequence";

set feedback on heading on

set termout off

column tracefile noprint new_value trc

SELECT value tracefile FROM v$diag_info WHERE name = 'Default Trace File';

-- this is from from old 9i/10g days...
--
--	select value ||'/'||(select instance_name from v$instance) ||'_ora_'||
--	       (select spid||case when traceid is not null then '_'||traceid else null end
--                from v$process where addr = (select paddr from v$session
--	                                         where sid = (select sid from v$mystat
--	                                                    where rownum = 1
--	                                               )
--	                                    )
--	       ) || '.trc' tracefile
--	from v$parameter where name = 'user_dump_dest';

set termout on
@@loadset

prompt New tracefile_identifier=&trc

col tracefile print

