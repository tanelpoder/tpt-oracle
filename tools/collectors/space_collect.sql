-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- this script requires PLANCAP_COLLECTOR package
-- which is created using these scripts
-- 1) plancap_collector_schema.sql
-- 2) plancap_collector.sql

EXEC SNAP_DATA_FILES
EXEC SNAP_FREE_SPACE
EXEC SNAP_SEGMENT_SPACE
EXEC SNAP_SERVICE_STATS

