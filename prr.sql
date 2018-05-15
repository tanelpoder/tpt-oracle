-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Notes:   This script is based on Tom Kyte's original printtbl code ( http://asktom.oracle.com )
--          For coding simplicity I'm using custom quotation marks ( q'\ ) so this script works
--          from Oracle 10gR2 onwards

@@saveset
set serverout on size 1000000 termout off
save pr_&_connect_identifier..tmp replace
set termout on

0 c clob := q'\
0 declare

999999      \';;
999999      l_theCursor     integer default dbms_sql.open_cursor;;
999999      l_columnValue   varchar2(4000);;
999999      l_status        integer;;
999999      l_descTbl       dbms_sql.desc_tab;;
999999      l_colCnt        number;;
999999  begin
999999      dbms_sql.parse(  l_theCursor, c, dbms_sql.native );;
999999      dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );;
999999      for i in 1 .. l_colCnt loop
999999          dbms_sql.define_column( l_theCursor, i,
999999                                  l_columnValue, 4000 );;
999999      end loop;;
999999      l_status := dbms_sql.execute(l_theCursor);;
999999      while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
999999          for i in 1 .. l_colCnt loop
999999              if regexp_like(lower(l_descTbl(i).col_name), lower('&1')) then
999999                  dbms_sql.column_value( l_theCursor, i,
999999                                         l_columnValue );;
999999                  dbms_output.put_line
999999                      ( rpad( l_descTbl(i).col_name,
999999                        30 ) || ': ' || l_columnValue );;
999999              end if;;
999999          end loop;;
999999          dbms_output.put_line( '==============================' );;
999999      end loop;;
999999  exception
999999      when others then
999999          dbms_output.put_line(dbms_utility.format_error_backtrace);;
999999          raise;;
999999 end;;
/

@@loadset

get pr_&_connect_identifier..tmp nolist
host del pr_&_connect_identifier..tmp
