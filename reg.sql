-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

PROMPT Querying DBA_REGISTRY_HISTORY ...
--SELECT action_time, bundle_series, comments FROM dba_registry_history ORDER BY action_time ASC;
SELECT * FROM dba_registry_history ORDER BY action_time ASC;
