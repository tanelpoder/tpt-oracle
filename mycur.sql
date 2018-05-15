-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL mycur_bind_mem_loc HEAD BIND_MEM FOR A8

SELECT
    curno
  , '0x'||TRIM(TO_CHAR(flag, '0XXXXXXX')) flag
  , status
  , parent_handle            par_hd
  , parent_lock              par_lock
  , child_handle             ch_hd
  , child_lock               ch_lock
  , child_pin                ch_pin
  , pers_heap_mem
  , work_heap_mem
  , bind_vars
  , define_vars
  , bind_mem_loc              mycur_bind_mem_loc
--  , inst_flag
--  , inst_flag2
FROM
    v$sql_cursor
WHERE
    status != 'CURNULL'
/
