prompt Display indexes where table or index name matches &1....

column ind_table_name heading TABLE_NAME format a30
column ind_index_name heading INDEX_NAME format a30
column ind_table_owner heading TABLE_OWNER format a20
column ind_column_name heading COLUMN_NAME format a30
column ind_column_position heading POS format 999
column ind_column_expression heading COLUMN_EXPRESSION format a100 word_wrap
break on ind_table_owner1 skip 1 on ind_table_name1 on ind_index_name1

SELECT
   table_owner             ind_table_owner
 , table_name              ind_table_name
 , index_name              ind_index_name
 , column_position         ind_column_position
 , column_expression       ind_column_expression
FROM
   dba_ind_expressions
WHERE (
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
ORDER BY
    table_owner
  , table_name
  , index_name
  , column_position
/

