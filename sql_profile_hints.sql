-- This script will show existing SQL profile hints.
--
-- FYI with a different query you can also view what profiles would be created if you accept a SQL Tuning task result:
--   https://blog.dbi-services.com/oracle-sql-profiles-check-what-they-do-before-accepting-them-blindly/

SELECT
    hint outline_hints
FROM (
    SELECT p.name, p.signature, p.category, ROW_NUMBER()
    OVER (PARTITION BY d.signature, d.category ORDER BY d.signature) row_num,
    EXTRACTVALUE(VALUE(t), '/hint') hint
    FROM 
        sys.sqlobj$data d
      , dba_sql_profiles p,
    TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(d.comp_data), '/outline_data/hint'))) t
WHERE
    d.obj_type = 1
AND p.signature = d.signature
AND p.category = d.category
AND p.name LIKE ('&1'))
ORDER BY 
    name
  , row_num
/

