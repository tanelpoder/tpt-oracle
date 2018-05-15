-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set feedback off

prompt Display indexes where table or index name matches &1....

column ind_table_name1 heading TABLE_NAME format a30
column ind_index_name1 heading INDEX_NAME format a30
column ind_table_owner1 heading TABLE_OWNER format a20
column ind_column_name1 heading COLUMN_NAME format a30
column ind_dsc1 heading DSC format a4
column ind_column_position1 heading POS# format 999

break on ind_table_owner1 skip 1 on ind_table_name1 on ind_index_name1


select 
    c.table_owner ind_table_owner1,
    c.table_name ind_table_name1, 
    c.index_name ind_index_name1, 
    c.column_position ind_column_position1, 
    c.column_name ind_column_name1, 
    decode(c.descend,'DESC','DESC',null) ind_dsc1
from 
    dba_ind_columns c
where (
    UPPER(table_name) LIKE 
                UPPER(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND UPPER(table_owner) LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
)
OR (
    UPPER(index_name) LIKE 
                UPPER(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND UPPER(index_owner) LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
)
order by
    c.table_owner,
    c.table_name,
    c.index_name,
    c.column_position
;

column ind_owner heading INDEX_OWNER format a20
column ind_index_type heading IDXTYPE format a10
column ind_uniq heading UNIQ format a4
column ind_degree heading DEGREE format a6
column ind_part heading PART format a4
column ind_temp heading TEMP format a4
column ind_blevel heading H format 9
column ind_leaf_blocks heading LFBLKS format 999999999
column ind_distinct_keys heading NDK format 999999999999

break on ind_owner on table_name

select 
    owner ind_owner, 
    table_name ind_table_name1, 
    index_name ind_index_name1, 
    index_type ind_index_type, 
    decode(uniqueness,'UNIQUE', 'YES', 'NONUNIQUE', 'NO', 'N/A') ind_uniq, 
    status, 
    partitioned ind_part, 
    temporary ind_temp,
    blevel+1 ind_blevel,
    leaf_blocks ind_leaf_blocks,
    distinct_keys ind_distinct_keys,
    num_rows,
    clustering_factor cluf,
    last_analyzed,
    degree    ind_degree
  , visibility -- 11g
from 
    dba_indexes
where (
    UPPER(table_name) LIKE 
                UPPER(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND UPPER(table_owner) LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
)
OR (
    UPPER(index_name) LIKE 
                UPPER(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND UPPER(owner) LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
)    
order by
    owner,
    table_name,
    index_name,
    ind_uniq
;

set feedback on
