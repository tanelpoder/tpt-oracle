-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL temp_username FOR A20 HEAD USERNAME
COL temp_tablespace FOR A20 HEAD TABLESPACE

SELECT 
    u.inst_id
  , u.username   temp_username
  , s.sid
  , u.session_num serial#
  , u.sql_id
  , u.tablespace temp_tablespace
  , u.contents
  , u.segtype
  , ROUND( u.blocks * t.block_size / (1024*1024) ) MB
  , u.extents
  , u.blocks
FROM 
    gv$tempseg_usage u
  , gv$session s
  , dba_tablespaces t
WHERE
    u.session_addr = s.saddr
AND u.inst_id = s.inst_id
AND t.tablespace_name = u.tablespace
ORDER BY
    mb DESC
/

