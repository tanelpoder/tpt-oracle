-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL sinfo_username FOR A30 HEAD USERNAME

SELECT sid, username sinfo_username, program, service_name, module, action, client_identifier, client_info, ecid, machine, port
FROM v$session WHERE paddr IN (SELECT addr FROM v$process WHERE spid IN (&1));

