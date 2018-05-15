-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

CREATE BIGFILE TABLESPACE big DATAFILE SIZE 100M AUTOEXTEND ON MAXSIZE 10G 
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 16M SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLE system.t_big TABLESPACE big PARALLEL 4 AS SELECT * FROM dba_source;

