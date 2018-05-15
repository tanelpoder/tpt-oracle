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
    prev_hash_value                                hash_value
  , prev_sql_id                                    sql_id
  , prev_child_number                              child_number
  , lower(to_char(prev_hash_value, 'XXXXXXXX'))    hash_hex
from 
    v$session 
where 
    sid = (select sid from v$mystat where rownum = 1)
/
