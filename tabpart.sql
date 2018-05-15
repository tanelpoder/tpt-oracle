-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col tabpart_high_value head HIGH_VALUE_RAW for a100
col table_owner for a30
col table_name for a30
col partition_name for a30

select
    table_owner        
  , table_name         
  , partition_position pos
  , composite          
  , partition_name     
  , num_rows
  , subpartition_count 
  , high_value         tabpart_high_value
  , high_value_length 
  , compression
  , compress_for
from
    dba_tab_partitions
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
  , partition_position
/
