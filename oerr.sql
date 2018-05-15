-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- OERR functionality - list description for and ORA- error code
-- The data comes from $ORACLE_HOME/rdbms/mesg/oraus.msb file
-- which is a binary compiled version of $ORACLE_HOME/rdbms/mesg/oraus.msg file


@@saveset
set serverout on size 1000000 feedback off
prompt
exec dbms_output.put_line(sqlerrm(-&1))
prompt
@@loadset
