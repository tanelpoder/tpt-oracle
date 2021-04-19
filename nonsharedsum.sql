-- Copyright 2021 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

@@saveset
set serverout on size 1000000

-- This is modified Tom Kyte's printtab code ( http://asktom.oracle.com )

declare
    l_theCursor     integer default dbms_sql.open_cursor;
    l_columnValue   varchar2(4000);
    l_status        integer;
    l_descTbl       dbms_sql.desc_tab;
    l_colCnt        number;

    l_colQuery      varchar2(1000) := 'select * from v$sql_shared_cursor where 1=0';
    l_dynQuery      clob := 'SELECT * FROM (SELECT sql_id, COUNT(DISTINCT address) parent_count, COUNT(*) child_count ' || chr(10);
    l_versionCount  number;

    procedure execute_immediate( p_sql in varchar2 )
    is
    begin
        dbms_sql.parse(l_theCursor,p_sql,dbms_sql.native);
        l_status := dbms_sql.execute(l_theCursor);
    end;
begin
    -- get list of interesting columns from v$sql_shared_cursor (list differs by DB version)
    dbms_sql.parse(l_theCursor, l_colQuery, dbms_sql.native);
    dbms_sql.describe_columns(l_theCursor, l_colCnt, l_descTbl);

    -- generate dynamic query
    for i in 1 .. l_colCnt loop
        if l_descTbl(i).col_type = 1 and l_descTbl(i).col_max_len = 1 then
            l_dynQuery := l_dynQuery || chr(10) || '    , SUM(CASE WHEN ' || (l_descTbl(i).col_name) 
                                     || ' = ''Y'' THEN 1 ELSE 0 END) AS ' || (l_descTbl(i).col_name);
        end if;
    end loop;
  
    if '&1' = '%' then l_versionCount := 10;  else l_versionCount := 0; end if;
    l_dynQuery := l_dynQuery || chr(10) 
                             || '    FROM v$sql_shared_cursor '
                             || '    WHERE sql_id LIKE ''&1'' GROUP BY sql_id HAVING COUNT(*) > '
                             || l_versionCount ||') ORDER BY child_count DESC';

    if l_versionCount != 0 then dbms_output.put_line('Showing statements with version count > '||l_versionCount); end if;
    dbms_output.put_line(chr(8));
    -- run dynamic query
    dbms_sql.parse(l_theCursor, l_dynQuery, dbms_sql.native);
    dbms_sql.describe_columns(l_theCursor, l_colCnt, l_descTbl);

    for i in 1 .. l_colCnt loop
        dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000);
    end loop;
    
    l_status := dbms_sql.execute(l_theCursor);
    
    while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
        for i in 1 .. l_colCnt loop
            dbms_sql.column_value( l_theCursor, i, l_columnValue );
            if trim(l_columnValue) != '0' then
                dbms_output.put_line ( rpad( l_descTbl(i).col_name, 35 ) || ': ' 
                                    || substr(l_columnValue,1,220)
                                    || CASE WHEN LENGTH(l_columnValue) > 220 THEN '...' ELSE '' END );
            end if;
        end loop;
        dbms_output.put_line( '-----------------' );
    end loop;
end;
/

@@loadset
