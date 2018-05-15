-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

@@saveset
set serverout on size 1000000

-- Tom Kyte's printtbl code ( http://asktom.oracle.com )

declare
    l_theCursor     integer default dbms_sql.open_cursor;
    l_columnValue   varchar2(4000);
    l_status        integer;
    l_descTbl       dbms_sql.desc_tab;
    l_colCnt        number;
    procedure execute_immediate( p_sql in varchar2 )
    is
    BEGIN
        dbms_sql.parse(l_theCursor,p_sql,dbms_sql.native);
        l_status := dbms_sql.execute(l_theCursor);
    END;
begin

    execute_immediate( 'alter session set nls_date_format=
                        ''dd-mon-yyyy hh24:mi:ss'' ');
    dbms_sql.parse(  l_theCursor,
                     replace( '&1', '"', ''''),
                     dbms_sql.native );
    dbms_sql.describe_columns( l_theCursor,
                               l_colCnt, l_descTbl );
    for i in 1 .. l_colCnt loop
        dbms_sql.define_column( l_theCursor, i,
                                l_columnValue, 4000 );
    end loop;
    l_status := dbms_sql.execute(l_theCursor);
    while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
        for i in 1 .. l_colCnt loop
            dbms_sql.column_value( l_theCursor, i,
                                   l_columnValue );
            dbms_output.put_line
                ( rpad( l_descTbl(i).col_name,
                  30 ) || ': ' || l_columnValue );
        end loop;
        dbms_output.put_line( '-----------------' );
    end loop;
    execute_immediate( 'alter session set nls_date_format=
                           ''dd-MON-yy'' ');
exception
    when others then
        execute_immediate( 'alter session set
                         nls_date_format=''dd-MON-yy'' ');
        raise;
end;
/

@@loadset
