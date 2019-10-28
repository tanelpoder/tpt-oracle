VAR sql_fulltext CLOB
EXEC SELECT sql_fulltext INTO :sql_fulltext FROM v$sql WHERE sql_id = '1ka5g0kh4h6pc' AND rownum = 1;

-- Example 1: Set Join order:
EXEC DBMS_SQLTUNE.IMPORT_SQL_PROFILE(sql_text=>:sql_fulltext, profile=>sys.sqlprof_attr('LEADING(@"SEL$1" "CO"@"SEL$1" "CH"@"SEL$1" "CU"@"SEL$1" "S"@"SEL$1" "P"@"SEL$1")'), name=> 'MANUAL_PROFILE_1k

-- Example 2: Adjust cardinality:
EXEC DBMS_SQLTUNE.IMPORT_SQL_PROFILE(sql_text=>:sql_fulltext, profile=>sys.sqlprof_attr('OPT_ESTIMATE(@"SEL$1", TABLE, "CU"@"SEL$1", SCALE_ROWS=100000)'), name=> 'MANUAL_PROFILE_1ka5g0kh4h6pc');

-- Example 3: Set multiple hints:
DECLARE
    hints sys.sqlprof_attr := sys.sqlprof_attr(
        ('LEADING(@"SEL$1" "CO"@"SEL$1" "CH"@"SEL$1")')
      , ('OPT_ESTIMATE(@"SEL$1", TABLE, "CU"@"SEL$1", SCALE_ROWS=100000)')
    );
BEGIN
    DBMS_SQLTUNE.IMPORT_SQL_PROFILE(sql_text=>:sql_fulltext, profile=> hints, name=> 'MANUAL_PROFILE_1ka5g0kh4h6pc');
END;
/

-- Example 4: SwingBench TPCDS-Like Query 31 skip scan issue (force match)
-- alternative option would be to use opt_param('_optimizer_skip_scan_enabled','false')

DECLARE
    hints sys.sqlprof_attr := sys.sqlprof_attr(
        ('NO_INDEX_SS(@"SEL$26CA4453" "STORE_SALES"@"SEL$1")')
      , ('NO_INDEX_SS(@"SEL$2C2C13D8" "WEB_SALES"@"SEL$2")')
    );
BEGIN
    DBMS_SQLTUNE.IMPORT_SQL_PROFILE(sql_text=>:sql_fulltext, profile=> hints, name=> 'QUERY31_DISABLE_SKIP_SCAN', force_match=> TRUE);
END;
/

DECLARE
    hints sys.sqlprof_attr := sys.sqlprof_attr(
        ('NO_INDEX(@"SEL$26CA4453" "STORE_SALES"@"SEL$1")')
      , ('NO_INDEX(@"SEL$2C2C13D8" "WEB_SALES"@"SEL$2")')
    );
BEGIN
    DBMS_SQLTUNE.IMPORT_SQL_PROFILE(sql_text=>:sql_fulltext, profile=> hints, name=> 'QUERY31_DISABLE_SKIP_SCAN', force_match=> TRUE);
END;
/


