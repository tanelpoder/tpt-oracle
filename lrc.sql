-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT 
    lc.addr                                     child_addr#
--  , lc.child#                                   child_latch#
  , kqrstcid																		cache#
	,	s.kqrsttxt                                  name
  , decode(s.kqrsttyp,1,'PARENT','SUBORDINATE') type
  , decode(s.kqrsttyp,2,s.kqrstsno,null)        subordinate#
  , lc.gets
  , lc.misses
  , lc.sleeps
--, lc.spin_gets
FROM 
    x$kqrst s
  , v$latch_children lc
WHERE 
    lc.child# = s.kqrstcln
AND lc.name   = 'row cache objects'
AND kqrstcid LIKE '&1'
ORDER BY
    cache#
  , type
  , subordinate#
/

