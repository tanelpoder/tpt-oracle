-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINES 1000 PAGES 5000 TRIMSPOOL ON TRIMOUT ON TAB OFF

COL owner FOR A15
COL object_name FOR A30

WITH trends AS (
    SELECT
        o.owner
      , o.object_name
      , o.subobject_name
      , o.object_type
      , MIN(ih.savtime) first_sample
      , MAX(ih.savtime) last_sample
      , REGR_SLOPE(ih.rowcnt / NULLIF(ih.leafcnt,0), (SYSDATE-CAST(ih.savtime AS DATE)) ) regr1
      , REGR_SLOPE(ih.rowcnt, ih.leafcnt) regr2
      , ROUND(MIN(ih.rowcnt / NULLIF(ih.leafcnt,0))) min_avg_rows_per_block
      , ROUND(MAX(ih.rowcnt / NULLIF(ih.leafcnt,0))) max_avg_rows_per_block
      , MIN(ih.rowcnt)                               min_rowcnt
      , MAX(ih.rowcnt)                               max_rowcnt
      , MIN(ih.leafcnt)                              min_leafcnt
      , MAX(ih.leafcnt)                              max_leafcnt
      , MIN(ih.lblkkey)                              min_lblkkey
      , MAX(ih.lblkkey)                              max_lblkkey
      , MIN(ih.dblkkey)                              min_dblkkey
      , MAX(ih.dblkkey)                              max_dblkkey
      , MIN(ih.blevel)+1                             min_height              
      , MAX(ih.blevel)+1                             max_height
    FROM
        dba_objects o
      , sys.wri$_optstat_ind_history ih
    WHERE
        o.object_id       = ih.obj#
    AND o.object_type     LIKE 'INDEX%'
    AND (
        UPPER(o.object_name) LIKE
                    UPPER(CASE
                        WHEN INSTR('&1','.') > 0 THEN
                            SUBSTR('&1',INSTR('&1','.')+1)
                        ELSE
                            '&1'
                        END
                         )
    AND UPPER(o.owner) LIKE
            CASE WHEN INSTR('&1','.') > 0 THEN
                UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
            ELSE
                user
            END
    )
    GROUP BY
        o.owner
      , o.object_name
      , o.subobject_name
      , o.object_type
    ORDER BY
    --    ih.savtime
        regr1 DESC NULLS LAST
)
SELECT * FROM (
    SELECT
        t.owner
      , t.object_name
      , t.subobject_name partition_name
      , t.object_type
      , ROUND(s.bytes / 1048576) current_mb
      , CAST(first_sample AS DATE) first_sample
      , CAST(last_sample  AS DATE) last_sample
      , min_avg_rows_per_block
      , max_avg_rows_per_block
      , min_leafcnt
      , max_leafcnt
      , min_lblkkey
      , max_lblkkey
      , min_dblkkey
      , max_dblkkey
      , t.regr1
      , t.regr2
      --, ROUND(SUM(s.bytes) / 1048576) mb_sum
      --, COUNT(*)
    FROM
        trends t
      , dba_segments s
    WHERE
        t.owner           = s.owner
    AND t.object_name     = s.segment_name
    AND t.object_type     = s.segment_type
    AND (t.subobject_name = s.partition_name OR (t.subobject_name IS NULL AND s.partition_name IS NULL))
    --GROUP BY
    --    t.owner
    --  , t.object_name
    --  , t.object_type
    --  , t.subobject_name
    ORDER BY regr1 DESC NULLS LAST
)
WHERE
    ROWNUM<=20
/ 
