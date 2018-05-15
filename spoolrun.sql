-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

def _spool_extension=&1

spool %SQLPATH%/tmp/output_&_connect_identifier..&_spool_extension
@&2
spool off

host start %SQLPATH%/tmp/output_&_connect_identifier..&_spool_extension
undef _spool_extension
