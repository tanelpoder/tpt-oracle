-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT t.tablespace_name, b.ts#, t.block_size, b.status, COUNT(*) num_bufs, ROUND(COUNT(*) * t.block_size / 1048576) pool_mb FROM v$bh b, dba_tablespaces t, v$tablespace vt WHERE b.ts# = vt.ts# AND vt.name = t.tablespace_name GROUP BY t.tablespace_name, b.ts#, t.block_size, b.status ORDER BY COUNT(*) DESC;


