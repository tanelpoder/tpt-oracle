-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   tptsleep

-- Purpose:     Create tpt$sleep function which allows sleeping during SQL 
--              execution
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       select a,b,c,tpt$sleep(10) from t

--
-- Other:       Used for high frequency V$/X$ sampling via plain SQL
--
--------------------------------------------------------------------------------

create or replace function tptsleep (sec in number default 1) return number as
--------------------------------------------------------------------------------
-- tpt$sleep by Tanel Poder ( http://www.tanelpoder.com )
--------------------------------------------------------------------------------
begin
     dbms_lock.sleep(sec);
     return 1;
end;
/

grant execute on tptsleep to public;

begin
    execute immediate 'drop public synonym tptsleep';
exception
    when others then null;
end;
/

create public synonym tptsleep for tptsleep;
