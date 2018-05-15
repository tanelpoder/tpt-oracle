-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   lotspios.sql
-- Purpose:     Generate Lots of Physical IOs for testing purposes
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @lotspios <number>
--              @lotspios 100
--              @lotspios 1000000
--          
-- Other:       This script just does a full table scan on all tables it can
--              see, thus it generates mainly scattered or direct path reads
--              
--------------------------------------------------------------------------------

prompt Generate lots of physical IOs by full scanning through all available tables...

declare
   str varchar2(1000);
   x number;
begin

   for i in 1..&1 loop
       for t in (select owner, table_name from all_tables where (owner,table_name) not in (select owner,table_name from all_external_tables)) loop
               begin
                       execute immediate 'select /*+ FULL(t) */ count(*) from '||t.owner||'.'||t.table_name||' t' into x;
               exception
                       when others then null;
               end;
       end loop; -- t
    end loop; -- i
end;
/
