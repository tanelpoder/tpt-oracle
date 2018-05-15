-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   rowcache.sql
-- Purpose:     Show parent rowcache entries mathcing an object name
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @rowcache <objectname>
-- 	            @rowcache dba_tables
--	        
-- Other:       Tested on Oracle 10.2 and 11.1, v$rowcache_parent doesnt seem
--              to return all rowcache entries in 9.2
--
--------------------------------------------------------------------------------

COL rowcache_cache_name HEAD CACHE_NAME FOR A20
COL rowcache_key HEAD KEY FOR A32 WRAP
COL rowcache_existent HEAD EXIST FOR A5

SELECT 
	INDX, HASH, ADDRESS,
	EXISTENT rowcache_existent, 
	CACHE#, 
	CACHE_NAME rowcache_cache_name,
--	LOCK_MODE, LOCK_REQUEST, TXN, SADDR, 
        RAWTOHEX(KEY) rowcache_key
FROM 
	v$rowcache_parent 
WHERE 
	RAWTOHEX(KEY) LIKE (
	    SELECT '%'||UPPER(REPLACE(SUBSTR(DUMP(UPPER('&1'),16),INSTR(DUMP(UPPER('&1'),16),': ')+2), ',', ''))||'%' 
	    FROM DUAL
	)
/
