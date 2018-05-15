-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show execution plan operations and options matching &1 (11g+)

SELECT RPAD('OPERATION',20) "TYPE", indx, TO_CHAR(indx,'XX') hex, xplton_name FROM x$xplton WHERE lower(xplton_name) LIKE lower('%&1%')
UNION ALL
SELECT 'OPTION', indx, TO_CHAR(indx,'XX'), xpltoo_name FROM x$xpltoo WHERE lower(xpltoo_name) LIKE lower('%&1%')
/
 
