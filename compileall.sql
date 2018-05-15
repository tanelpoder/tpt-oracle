-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt
prompt Generating the compile commands into compileall_out.sql...

set head off pages 0 lines 200 feed off trimspool on termout off

spool compileall_out.sql

select 
    'alter '||decode(object_type, 'PACKAGE BODY', 'PACKAGE', object_type)||' '
    ||owner||'.'||object_name||' compile'||
    decode(object_type, 'PACKAGE BODY', ' BODY;', ';') 
from 
    dba_objects 
where 
    object_type in ('PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION', 'TRIGGER');

spool off

set termout on

prompt Done.
prompt Now review the compileall_out.sql and execute it as SYS.
prompt Press enter to continue...
pause
