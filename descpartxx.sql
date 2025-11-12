-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- requires 12c or later as it uses inline WITH PL/SQL functions. It is possible to convert this
-- to 11g too, using the function which is included in the comment section below (see descxx11.sql)

COL column_id       HEAD "Col#"         FOR A4
COL column_name     HEAD "Column Name"  FOR A30
COL nullable        HEAD "Null?"        FOR A10
COL data_type       HEAD "Type"         FOR A25 WORD_WRAP
COL num_distinct    HEAD "# distinct"   FOR 999999999999999
COL density         HEAD "Density"      FOR 9.99999999999
COL num_nulls       HEAD "# nulls"      FOR 999999999999999
COL histogram       HEAD "Histogram"    FOR A10 TRUNCATE
COL num_buckets     HEAD "# buckets"    FOR 999999
COL low_value       HEAD "Low Value"    FOR A32
COL high_value      HEAD "High Value"   FOR A32
COL partition_name  HEAD PARTITION_NAME FOR A20
WITH
    FUNCTION display_raw(rawval RAW, type VARCHAR2)
    RETURN VARCHAR2
    IS 
        cn  NUMBER;
        cv  VARCHAR2(128);
        cd  DATE;
        cnv NVARCHAR2(128);
        cr  ROWID;
        cc  CHAR(128);
    BEGIN
        IF (type = 'NUMBER') THEN
            dbms_stats.convert_raw_value(rawval, cn);
            RETURN to_char(cn);
        ELSIF (type = 'VARCHAR2' OR type = 'CHAR') THEN
            dbms_stats.convert_raw_value(rawval, cv);
            RETURN to_char(cv);
        ELSIF (type = 'DATE') THEN
            dbms_stats.convert_raw_value(rawval, cd);
            RETURN to_char(cd);
        ELSIF (type = 'NVARCHAR2') THEN
            dbms_stats.convert_raw_value(rawval, cnv);
            RETURN to_char(cnv);
        ELSIF (type = 'ROWID') THEN
            dbms_stats.convert_raw_value(rawval, cr);
            RETURN to_char(cr);
        ELSIF (type = 'VARCHAR2') THEN
            dbms_stats.convert_raw_value(rawval, cc);
            RETURN to_char(cc);
        ELSE
            RETURN 'UNKNOWN DATATYPE';
        END IF;
    END;
SELECT
      cs.partition_name 
    , CASE WHEN tc.hidden_column = 'YES' THEN 'H' ELSE ' ' END || LPAD(column_id, 3) AS column_id
    , tc.column_name
    , CASE WHEN nullable = 'N' THEN 'NOT NULL' ELSE NULL END AS nullable
    , data_type || CASE 
                    WHEN data_type = 'NUMBER' THEN '(' || data_precision || ',' || data_scale || ')'
                    ELSE '(' || data_length || ')'
                    END AS data_type
    , cs.num_distinct
    , cs.density
    , cs.num_nulls
    , CASE WHEN cs.histogram = 'NONE' THEN null ELSE cs.histogram END AS histogram
    , cs.num_buckets
    , display_raw(cs.low_value, data_type) AS low_value 
    , display_raw(cs.high_value, data_type) AS high_value
    , notes
FROM dba_tab_cols tc,
     dba_part_col_statistics cs
WHERE
    tc.owner = cs.owner (+)
AND tc.table_name = cs.table_name (+)
AND tc.column_name = cs.column_name (+)
AND upper(tc.table_name) LIKE
                        upper(CASE
                                WHEN INSTR('&1','.') > 0 THEN
                                    SUBSTR('&1',INSTR('&1','.')+1)
                                ELSE
                                    '&1'
                                END
                             )
    AND tc.owner LIKE
                CASE WHEN INSTR('&1','.') > 0 THEN
                    UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
                ELSE
                    user
                END
    AND UPPER(cs.partition_name) LIKE UPPER('&2')
    AND UPPER(tc.column_name) LIKE UPPER('&3')
ORDER BY
    tc.owner, tc.table_name, tc.column_id,
    cs.partition_name
/
