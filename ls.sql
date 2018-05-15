-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col ls_file_name head FILE_NAME for a80
col ls_mb head MB
col ls_maxsize head MAXSZ

select 
    tablespace_name,
    file_id,
    file_name ls_file_name,
    autoextensible ext,
    round(bytes/1048576,2) ls_mb,
    decode(autoextensible, 'YES', round(maxbytes/1048576,2), null) ls_maxsize
from
    (select tablespace_name, file_id, file_name, autoextensible, bytes, maxbytes from dba_data_files where upper(tablespace_name) like upper('%&1%')
     union all
     select tablespace_name, file_id, file_name, autoextensible, bytes, maxbytes from dba_temp_files where upper(tablespace_name) like upper('%&1%')
    )
order by
    tablespace_name,
    file_name
;
