-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   demos/cse.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--
--              Demonstrating common subexpression elimination transformation
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
--
-- Copyright:   (c) 2007-2009 Tanel Poder
--
--------------------------------------------------------------------------------

set serverout on size 1000000

create or replace function imhere( par in varchar2 )
    return varchar2
as
begin
    dbms_output.put_line('i''m here!: '||par);
    return par;
end;
/


@pd eliminate_common_subexpr

set echo on

select /*+ ORDERED_PREDICATES tanel1 */ * 
from dual 
where 
   (imhere(dummy) = 'X' and length(dummy) = 10) 
or (imhere(dummy) = 'X' and length(dummy) = 11)
/

alter session set "_eliminate_common_subexpr"=false;

select /*+ ORDERED_PREDICATES tanel2 */ * 
from dual 
where 
   (imhere(dummy) = 'X' and length(dummy) = 10) 
or (imhere(dummy) = 'X' and length(dummy) = 11)
/

set echo off

select /*+ tanel3 */ * 
from dual 
where 
   (imhere(dummy) = 'X' and length(dummy) = 10) 
or (imhere(dummy) = 'X' and length(dummy) = 11)
/
