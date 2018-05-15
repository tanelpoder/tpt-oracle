-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show top space users per tablespace - collapse partitions to table/index level

col topseg_seg_owner HEAD OWNER FOR A30
col topseg_segment_name head SEGMENT_NAME for a30
col topseg_segment_type head SEGMENT_TYPE for a30

select * from (
    select
        tablespace_name,
        owner,
        segment_name topseg_segment_name,
        --partition_name,
        REPLACE(segment_type, ' PARTITION', ' - PARTITIONED') topseg_segment_type,
        count(*),
        round(sum(bytes)/1048576) MB
    from dba_segments
    where upper(tablespace_name) like upper('%&1%')
    group by tablespace_name, owner, segment_name, segment_type
    order by MB desc
)
where rownum <= 30;

