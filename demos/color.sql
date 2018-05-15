-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select
     color(lpad(' ',20), trunc(mod((r+0)/36,6)),   trunc(mod((r+0)/6,6)),   trunc(mod((r+0),6)) ) 
  || color(lpad(' ',20), trunc(mod((r+0)/36,6))+0, trunc(mod((r+0)/6,6))+0, trunc(mod((r+0),6))+0 ) 
  || color(lpad(' ',20), trunc(mod((r+0)/36,6))+0, trunc(mod((r+0)/6,6))+0, trunc(mod((r+0),6))+0 ) 
  || color(lpad(' ',20), trunc(mod((r+0)/36,6))+0, trunc(mod((r+0)/6,6))+0, trunc(mod((r+0),6))+0 ) 
  || color(lpad(' ',20), trunc(mod((r+0)/36,6))+0, trunc(mod((r+0)/6,6))+0, trunc(mod((r+0),6))+0 ) 
  || color(lpad(' ',20), trunc(mod((r+0)/36,6))+0, trunc(mod((r+0)/6,6))+0, trunc(mod((r+0),6))+0 )
from
    (select rownum - 1 r from dual connect by level <= 36*6)
/

