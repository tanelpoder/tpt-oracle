-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col tabpart_high_value head HIGH_VALUE_RAW for a100
col partition_name for a30
col subpartition_name for a30

select
    table_owner
  , table_name
  , partition_name
  , subpartition_name
  , subpartition_position sub_pos
  , num_rows
  , high_value         tabpart_high_value
  , high_value_length
From
    dba_tab_subpartitions
where
    upper(table_name) LIKE
                upper(CASE
                    WHEN INSTR('&1','.') > 0 THEN
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND table_owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
ORDER BY
    table_owner
  , table_name
  , partition_name
  , subpartition_position
/
