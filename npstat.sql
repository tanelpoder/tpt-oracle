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
    'numa pool' pool_name
  , ksmnssidx
  , ksmnsprocgrp
  , ROUND(SUM(CASE WHEN ksmnsnam = 'free memory' THEN 0 ELSE ksmnslen END)/1048576) mb_used
  , ROUND(SUM(CASE WHEN ksmnsnam = 'free memory' THEN ksmnslen ELSE 0 END)/1048576) mb_free
  , ROUND(SUM(ksmnslen)/1048576) mem_total
from x$ksmns    
group by
    'numa pool' 
  , ksmnssidx
  , ksmnsprocgrp
order by
    1,2,3
/

SELECT
    'numa pool' pool_name
  , ksmnssidx
  , ksmnsprocgrp
  , ksmnsnam
  , ROUND(sum(ksmnslen)/1048576) mb
from x$ksmns
where lower(ksmnsnam) like lower('%&1%')   
group by
    'numa pool'
  , ksmnssidx
  , ksmnsprocgrp
  , ksmnsnam
order by
    1,2,3
/


BREAK ON sgastatx_subpool DUP
