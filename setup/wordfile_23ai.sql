-- Copyright 2024 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set lines 5000 trimspool on pages 0 head off feedback off termout off

SELECT DISTINCT name FROM (
    select lower(keyword) name from v$reserved_words union all
    select upper(table_name) from dict union all
    select upper(table_name)||'.'||upper(column_name) from dict_columns union all
    -- select object_name from dba_objects union all
    -- select upper(object_name||'.'||procedure_name) from dba_procedures union all
    -- select '"'||table_name||'".'||column_name from dba_tab_columns union all
    select ksppinm from x$ksppi union all
    select name from v$sql_hint union all
    /* 2024 full-send additions */
    SELECT
        UPPER(p.object_name||'.'||p.procedure_name)
        ||'('
        ||SUBSTR(
            LISTAGG( NVL(LOWER(argument_name),'/*func_ret=*/')||'=>'
                || CASE WHEN data_type LIKE '%CHAR%' OR data_type LIKE '%CLOB' OR data_type LIKE '%ROWID' 
                            THEN '''&'||LOWER(argument_name)||'_'||LOWER(replace(data_type, ' ', '_'))||''''
                        WHEN data_type LIKE '%RAW' 
                            THEN 'HEXTORAW(''&'||LOWER(argument_name)||'_'||LOWER(REPLACE(data_type, ' ', '_'))||''')'
                        ELSE '&'||LOWER(argument_name)||'_'||LOWER(REPLACE(data_type, ' ', '_')) 
                   END, 
                ',' ON OVERFLOW TRUNCATE ' -- truncated' WITH COUNT ) WITHIN GROUP (ORDER BY a.position)
            ||')', 1, 3900) objname
    FROM
        dba_procedures p
      , dba_arguments  a
    WHERE
            p.owner = a.owner
        AND p.object_name = a.package_name
        AND p.object_id = a.object_id
        AND p.subprogram_id = a.subprogram_id
        AND SYS_OP_MAP_NONNULL(p.overload) = SYS_OP_MAP_NONNULL(a.overload)
        AND a.defaulted = 'N'
    GROUP BY
          p.owner
        , p.object_name 
        , p.procedure_name
        , p.object_id
        , p.subprogram_id
    UNION ALL
    SELECT
        UPPER(p.object_name||'.'||p.procedure_name)
        ||'('
        ||SUBSTR(
            LISTAGG( NVL(LOWER(argument_name),'/*func_ret=*/')||'=>'
                || CASE WHEN data_type LIKE '%CHAR%' OR data_type LIKE '%CLOB' OR data_type LIKE '%ROWID' 
                            THEN '''&'||LOWER(argument_name)||'_'||LOWER(replace(data_type, ' ', '_'))||''''
                        WHEN data_type LIKE '%RAW' 
                            THEN 'HEXTORAW(''&'||LOWER(argument_name)||'_'||LOWER(REPLACE(data_type, ' ', '_'))||''')'
                        ELSE '&'||LOWER(argument_name)||'_'||LOWER(REPLACE(data_type, ' ', '_')) 
                   END, 
                ',' ON OVERFLOW TRUNCATE ' -- truncated' WITH COUNT ) WITHIN GROUP (ORDER BY a.position)
            ||')', 1, 3900) objname
    FROM
        dba_procedures p
      , dba_arguments  a
    WHERE
            p.owner = a.owner
        AND p.object_name = a.package_name
        AND p.object_id = a.object_id
        AND p.subprogram_id = a.subprogram_id
        AND SYS_OP_MAP_NONNULL(p.overload) = SYS_OP_MAP_NONNULL(a.overload)
        -- AND a.defaulted = 'N'
    GROUP BY
          p.owner
        , p.object_name 
        , p.procedure_name
        , p.object_id
        , p.subprogram_id
)
WHERE length(name) > 2
ORDER BY name
.

spool wordfile_23c.txt
/
spool off



-- select upper(p.object_name||'.'||p.procedure_name)||'('||LOWER(argument_name)||'=>&'||LOWER(argument_name)||'_'||LOWER(data_type)||')' from 
-- dba_procedures p, dba_arguments a WHERE p.owner = a.owner AND p.object_name = a.package_name AND p.object_id = a.object_id AND p.subprogram_id = 
-- a.subprogram_id AND p.overload = a.overload AND a.defaulted = 'N' AND p.object_name LIKE 'DBMS_STATS%' AND in_out LIKE 'IN%' ORDER BY 1, a.positi
-- on;

-- you can also add TPT scripts by running this in TPT script dir:
-- find . -type f -name "*.sql" | sed 's/^\.\///' | awk '{ print "@" $1 }' >> ~/work/oracle/wordfile_23c.txt
-- or you could just run rlwrap sqlplus while being in the directory where the scripts are located!!



