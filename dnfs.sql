-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL svrname FOR A20
COL dirname FOR A20
COL filename FOR A60
COL path    FOR A20
COL local   FOR A20

--SELECT 'MY_STATS' my_stats, s.* FROM v$dnfs_stats s WHERE pnum = (SELECT pid FROM v$process WHERE addr = (SELECT paddr FROM v$session WHERE sid = SYS_CONTEXT('USERENV', 'SID')));
SELECT 'STATS   ' my_stats, s.* FROM v$dnfs_stats s WHERE pnum IN (SELECT pnum FROM v$dnfs_channels) ORDER BY pnum;
SELECT 'SERVERS ' servers, s.* FROM v$dnfs_servers s;
SELECT 'CHANNELS' channels, c.* FROM v$dnfs_channels c;
SELECT 'FILES   ' files, f.* FROM v$dnfs_files f;

