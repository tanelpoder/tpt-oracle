-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   sgastatx
-- Purpose:     Show shared pool stats by sub-pool from X$KSMSS
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @sgastatx <statistic name>
-- 	        @sgastatx "free memory"
--	        @sgastatx cursor
--
-- Other:       The other script for querying V$SGASTAT is called sgastat.sql
--              
--              
--
--------------------------------------------------------------------------------

COL sgastatx_subpool HEAD SUBPOOL FOR a30

PROMPT
PROMPT -- All allocations:

SELECT
    'shared pool ('||NVL(DECODE(TO_CHAR(ksmdsidx),'0','0 - Unused',ksmdsidx), 'Total')||'):'  sgastatx_subpool
  , SUM(ksmsslen) bytes
  , ROUND(SUM(ksmsslen)/1048576,2) MB
FROM 
    x$ksmss
WHERE
    ksmsslen > 0
--AND ksmdsidx > 0 
GROUP BY ROLLUP
   ( ksmdsidx )
ORDER BY
    sgastatx_subpool ASC
/

BREAK ON sgastatx_subpool SKIP 1
PROMPT -- Allocations matching "&1":

SELECT 
    subpool sgastatx_subpool
  , name
  , SUM(bytes)                  
  , ROUND(SUM(bytes)/1048576,2) MB
FROM (
    SELECT
        'shared pool ('||DECODE(TO_CHAR(ksmdsidx),'0','0 - Unused',ksmdsidx)||'):'      subpool
      , ksmssnam      name
      , ksmsslen      bytes
    FROM 
        x$ksmss
    WHERE
        ksmsslen > 0
    AND LOWER(ksmssnam) LIKE LOWER('%&1%')
)
GROUP BY
    subpool
  , name
ORDER BY
    subpool    ASC
  , SUM(bytes) DESC
/

BREAK ON sgastatx_subpool DUP
