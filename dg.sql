-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

PROMPT == v$database
SELECT name,open_mode,database_role FROM v$database;
PROMPT == v$dataguard_config
SELECT * FROM v$dataguard_config;
PROMPT == v$managed_standby
SELECT process,status,sequence# FROM v$managed_standby;
PROMPT == v$recovery_progress
SELECT item, units, sofar, total, start_time, type FROM v$recovery_progress;

