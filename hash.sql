-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   hash.sql
-- Purpose:     Show the hash value, SQL_ID and child number of previously
--              executed SQL in session
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @hash
-- 	        
--	        
-- Other:       Doesn't work on 9i for 2 reasons. There appears to be a bug
--              with v$session.prev_hash_value in 9.2.x and also there's no
--              SQL_ID nor CHILD_NUMBER column in V$SESSION in 9i.
--
--------------------------------------------------------------------------------

col hash_hex for a10

select 
    ses.prev_hash_value                                hash_value
  , ses.prev_sql_id                                    sql_id
  , ses.prev_child_number                              child_number
  , MOD(ses.prev_hash_value, 131072)                   kgl_bucket
  , (select sql.plan_hash_value 
     from v$sql sql 
     where 
         sql.sql_id = ses.prev_sql_id 
     and sql.child_number = ses.prev_child_number
     and sql.address = ses.prev_sql_addr)        plan_hash_value
  --, lower(to_char(ses.prev_hash_value, 'XXXXXXXX'))    hash_hex
  , ses.prev_exec_start                                sql_exec_start
  , ses.prev_exec_id                                   sql_exec_id
from 
    v$session ses
where 
    ses.sid = userenv('sid')
/
