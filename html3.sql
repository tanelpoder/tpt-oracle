-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set termout off markup html on spool on
spool output_&_connect_identifier..html

l
/
spool off

set termout on markup html off spool off
host start output_&_connect_identifier..html
