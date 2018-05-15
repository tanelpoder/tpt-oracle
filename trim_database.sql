-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- script	: trim_database.sql
-- purpose	: print alter database commands for trimming database files
-- author	: tanel poder 2006
-- issues	: doesnt resize tablespaces with no extents in them at all

with query as (
    select /*+ NO_MERGE MATERIALIZE */ 
        file_id, 
        tablespace_name,
        max(block_id + blocks) highblock
    from 
        dba_extents
    group by 
        file_id, tablespace_name
)
select 
    'alter database datafile '|| q.file_id || ' resize ' || ceil ((q.highblock * t.block_size + t.block_size)/1024)  || 'K;' cmd
from 
    query q,
    dba_tablespaces t
where
    q.tablespace_name = t.tablespace_name;



