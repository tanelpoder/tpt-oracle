-- script:  tabhisthybrid.sql
-- author:  Tanel Poder [tanelpoder.com)
-- created: Oct 2025 
-- usage:   @tabhisthybrid [<owner>.]<table_name> <column_name>
-- example: @tabhisthybrid soe.customers account_mgr_id
-- 
-- notes:
--   I reused the bucket/NewDensity logic already written by Mohamed Houri (and Alberto Dell'Era, Jonathan Lewis)
--   https://www.red-gate.com/simple-talk/databases/oracle-databases/12c-hybrid-histogram/
--
--   This script works with HYBRID histograms on NUMBER columns only for now.
--   I'm hoping to unify this script and my old tabhist.sql to show estimated cardinalities
--   (for equality filters) for all histogram types and data types someday.

COL table_owner            FORMAT A15
COL table_name             FORMAT A30
COL column_name            FORMAT A30
COL data_type              HEAD DATA_TYPE FORMAT A12
COL histogram_type         FORMAT A14
COL endpoint_number        FORMAT 9999999999
COL endpoint_value         FORMAT 9999999999
COL endpoint_actual_value  FORMAT A40
COL estimated_rows         FORMAT 9999999999
COL endpoint_repeat_count  FORMAT 999999
COL olddensity             FORMAT 0.00000000
COL newdensity             FORMAT 0.00000000

WITH col AS (
    SELECT
        t.owner
      , t.table_name
      , t.num_rows
      , c.column_name
      , c.data_type
      , c.histogram
      , c.sample_size
      , c.density AS OldDensity
      , (c.sample_size - c.num_nulls) AS BktCnt
      , c.num_distinct AS ndv
      , c.num_buckets
      , (c.sample_size - c.num_nulls) / c.num_buckets AS pop_bucketSize
    FROM 
        dba_tables t
      , dba_tab_columns c
    WHERE
    -- join
        t.owner       = c.owner
    AND t.table_name  = c.table_name
    -- filter
    AND UPPER(t.table_name)  = UPPER(CASE WHEN INSTR('&1','.')>0 THEN SUBSTR('&1',INSTR('&1','.')+1) ELSE '&1' END)
    AND UPPER(t.owner)       = UPPER(CASE WHEN INSTR('&1','.')>0 THEN SUBSTR('&1',1,INSTR('&1','.')-1) ELSE USER END)
    AND UPPER(c.column_name) = UPPER('&2')
),
hist AS (
    SELECT
        owner
      , table_name
      , column_name
      , endpoint_number
      , endpoint_repeat_count
      , endpoint_value
      , endpoint_actual_value
    FROM
        dba_tab_histograms
    WHERE
        UPPER(table_name)  = UPPER(CASE WHEN INSTR('&1','.')>0 THEN SUBSTR('&1',INSTR('&1','.')+1) ELSE '&1' END)
    AND UPPER(owner)       = UPPER(CASE WHEN INSTR('&1','.')>0 THEN SUBSTR('&1',1,INSTR('&1','.')-1) ELSE USER END)
    AND UPPER(column_name) = UPPER('&2')
),
bkt AS (
    -- newdensity calc for a column (returns 1 row as we are looking into one column of one table)
    SELECT
        COUNT(*) PopValCnt
      , SUM(endpoint_repeat_count) PopBktCnt
      , ndv
      , BktCnt
      , pop_bucketSize
    FROM
        col
      , hist
    WHERE
        endpoint_repeat_count > pop_bucketSize
    GROUP BY
        ndv
      , BktCnt
      , pop_bucketSize
),
nd AS (
    SELECT
        TRUNC(((BktCnt - PopBktCnt) / BktCnt) / (NDV - PopValCnt), 10) AS NewDensity
    FROM
        bkt
)
SELECT
    data_type                          AS data_type
  , histogram                          AS histogram_type
  , endpoint_value                     AS endpoint_value
  , CASE
        -- popular value
        WHEN
            histogram = 'HYBRID' AND NVL(endpoint_repeat_count, 0) > 1
        THEN
            ROUND(num_rows * (endpoint_repeat_count/sample_size))
        -- non-popular but is an endpoint
        WHEN
            histogram = 'HYBRID' AND NVL(endpoint_repeat_count, 0) = 1
        THEN
            ROUND(num_rows * LEAST(newdensity, endpoint_repeat_count / sample_size))
        -- TODO check if this condition does even exist in the wild
        WHEN 
            histogram = 'HYBRID' AND endpoint_number IS NULL
        THEN
            -1 
        ELSE
            NULL
    END                                AS card_thispop
  , TRUNC(c.num_rows * nd.newdensity)  AS card_nonpop
  , NVL(endpoint_repeat_count,0)       AS endpoint_repeat_count
--  , endpoint_number                    AS endpoint_number
--  , endpoint_actual_value              AS endpoint_actual_value
--  , olddensity                         AS olddensity
FROM
    col  c
  , hist h
  , nd -- single row
WHERE
    c.owner       = h.owner
AND c.table_name  = h.table_name
AND c.column_name = h.column_name
ORDER BY
    c.owner, c.table_name, c.column_name, h.endpoint_number
/
