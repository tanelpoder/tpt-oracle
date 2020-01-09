-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

PROMPT ORADEBUG DOC EVENT ACTION | grep -i &1
PROMPT
set termout off
spool oddc.tmp

oradebug doc event action	
spool off

host grep -i &1 oddc.tmp
host &_delete oddc.tmp

set termout on

prompt
prompt (spool is off)
