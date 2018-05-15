-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

@@saveset
set serveroutput on size 1000000

declare
    curr_sqlhash number;

    sqlhashes sys. 

begin
    for i in 1..50 loop
        select sql_hash_value into curr_sqlhash
        from v$session where sid = &1;   

        dbms_output.put_line(to_char(curr_sqlhash));

        dbms_lock.sleep(0.1);
    end loop;
end;
/

@@loadset
