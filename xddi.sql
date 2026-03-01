SET PAGESIZE 0 FEEDBACK OFF LINESIZE 32767 TRIMSPOOL ON TRIMOUT ON TAB OFF

SELECT JSON_SERIALIZE(
         JSON_ARRAYAGG(
           JSON_OBJECT(
             'id' VALUE id,
             'parent_id' VALUE parent_id,
             'depth' VALUE depth,
             'position' VALUE position,
             'operation' VALUE operation,
             'options' VALUE options,
             'object_owner' VALUE object_owner,
             'object_name' VALUE object_name,
             'object_alias' VALUE object_alias,
             'object_type' VALUE object_type,
             -- 'cost' VALUE cost,
             'cost' VALUE last_elapsed_time,
             -- 'cardinality' VALUE cardinality,
             'cardinality' VALUE last_output_rows,
             'bytes' VALUE bytes,
             'cpu_cost' VALUE cpu_cost,
             'io_cost' VALUE io_cost,
             'temp_space' VALUE temp_space,
             'access_predicates' VALUE access_predicates,
             'filter_predicates' VALUE filter_predicates,
             'projection' VALUE projection,
             'search_columns' VALUE search_columns,
             'partition_start' VALUE partition_start,
             'partition_stop' VALUE partition_stop,
             'actual_starts' VALUE last_starts,
             'actual_rows' VALUE last_output_rows,
             'actual_cr_buffer_gets' VALUE last_cr_buffer_gets,
             'actual_disk_reads' VALUE last_disk_reads,
             'actual_disk_writes' VALUE last_disk_writes,
             'actual_elapsed_time' VALUE last_elapsed_time,
             'actual_memory_used' VALUE last_memory_used,
             'actual_parallel_degree' VALUE last_degree,
             'actual_tempseg_size' VALUE last_tempseg_size
             ABSENT ON NULL
           )
           ORDER BY id
           RETURNING CLOB
         )
         RETURNING CLOB
         PRETTY
       ) AS json_plan
FROM
    v$sql_plan_statistics_all
WHERE
    sql_id = '&1'
AND child_number = &2
/

-- Could use this replacing the "/" above to spool text into a file
-- .
-- SPOOL sqlid_&1._&2..json
-- /
-- SPOOL OFF
-- PROMPT Spooled to file sqlid_&1._&2..json

SET PAGESIZE 500 FEEDBACK ON LINESIZE 1000

