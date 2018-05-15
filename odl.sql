-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- script by Tanel Poder (http://www.tanelpoder.com)

set termout off
spool odl.tmp

oradebug dumplist
spool off

host grep -i &1 odl.tmp | sort
host &_delete odl.tmp

set termout on

prompt
prompt (spool is off)
