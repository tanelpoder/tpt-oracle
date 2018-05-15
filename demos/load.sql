-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

alter session set plsql_optimize_level=0;

declare
   l_sid number;
begin
 
   select sid into l_sid from v$mystat where rownum = 1;

   while true loop
      execute immediate 'insert into t values('||to_char(l_sid)||')';
      execute immediate 'commit';
      execute immediate 'delete from t where a = '||to_char(l_sid);
      execute immediate 'commit';
   end loop;
end;
/
