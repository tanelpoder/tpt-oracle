-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL pdb_name FOR A30

SELECT con_id, dbid, name pdb_name, open_mode FROM v$pdbs;

