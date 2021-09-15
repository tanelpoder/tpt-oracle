-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show top space users per tablespace - collapse partitions to table/index level

col topseg_segment_name head SEGMENT_NAME for a30
col topseg_seg_owner HEAD OWNER FOR A30

select * from (
	select 
		round(SUM(bytes/1048576)) MB,
		tablespace_name, 
		owner topseg_seg_owner, 
		segment_name topseg_segment_name, 
		--partition_name,
		segment_type, 
    case when count(*) > 1 then count(*) else null end partitions
	from dba_segments
	where upper(tablespace_name) like upper('%&1%')
  group by
		tablespace_name, 
		owner, 
		segment_name,
		segment_type 
	order by MB desc nulls last
)
where rownum <= 30;

