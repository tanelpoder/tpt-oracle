-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col partkeys_column_name head COLUMN_NAME for a30
col partkeys_object_type HEAD OBJECT_TYPE FOR A11
col partkeys_owner HEAD OWNER FOR A30
col partkeys_name HEAD NAME FOR A30
col partkeys_level HEAD LEVEL FOR A6

with sq as (select '1_TOP' lvl, c.* from dba_part_key_columns c union all select '2_SUB', c.* from dba_subpart_key_columns c)
select
    object_type     partkeys_object_type
  , owner           partkeys_owner
  , name            partkeys_name
  , lvl             partkeys_level
  , column_name     partkeys_column_name
  , column_position 
from
    sq --dba_part_key_columns
where
    upper(name) LIKE 
                upper(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
ORDER BY
    object_type
  , owner
  , name
  , lvl
  , column_position
/

