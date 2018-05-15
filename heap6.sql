-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--select
--    /*+ ordered use_nl(hp) */
--    hp.*
--from
--    x$ksmsp sp
--  , x$ksmhp hp
--where
--    sp.ksmchptr = hp.ksmchds
--/
--
--COL sql_text FOR A80 TRUNCATE
--SELECT * FROM (
--    SELECT 
--        sql_id
--      , sharable_mem
--      , persistent_mem
--      , runtime_mem
--      , sql_text
--    FROM
--        V$SQL
--    ORDER BY
--        sharable_mem DESC
--)
--WHERE rownum <=10
--/
--
--COL sql_text CLEAR

SELECT 
    chunk_com, 
    alloc_class, 
    sum(chunk_size) totsize,
    count(*),
    count (distinct chunk_size) diff_sizes,
    round(avg(chunk_size)) avgsz,
    min(chunk_size) minsz,
    max(chunk_size) maxsz
FROM 
    v$sql_shared_memory 
WHERE 
    sql_id = '&1'
GROUP BY
    chunk_com,
    alloc_class
ORDER BY
    totsize DESC    
/
