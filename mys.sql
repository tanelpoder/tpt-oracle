-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL mys_value HEAD VALUE FOR 9999999999999999999

prompt Show current session's statistics from V$SESSTAT....

select 
	n.statistic# stat#,
	n.statistic# * 8 offset,
	n.name, 
	s.value mys_value,
  TRIM(
      CASE WHEN BITAND(class,  1) =   1 THEN 'USER  ' END ||
      CASE WHEN BITAND(class,  2) =   2 THEN 'REDO  ' END ||
      CASE WHEN BITAND(class,  4) =   4 THEN 'ENQ   ' END ||
      CASE WHEN BITAND(class,  8) =   8 THEN 'CACHE ' END ||
      CASE WHEN BITAND(class, 16) =  16 THEN 'OSDEP ' END ||
      CASE WHEN BITAND(class, 32) =  32 THEN 'PX    ' END ||
      CASE WHEN BITAND(class, 64) =  64 THEN 'SQLT  ' END ||
      CASE WHEN BITAND(class,128) = 128 THEN 'DEBUG ' END
   ) class_name
from v$mystat s, v$statname n
where s.statistic#=n.statistic#
and lower(n.name) like lower('%&1%')
/

