-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col seg_owner head OWNER for a20
col seg_segment_name head SEGMENT_NAME for a30
col seg_segment_type head SEGMENT_TYPE for a20
col seg_partition_name head SEG_PART_NAME for a30

select 
	round(bytes/1048576) seg_MB,
	owner seg_owner, 
	segment_name seg_segment_name, 
	partition_name seg_partition_name,
	segment_type seg_segment_type, 
	tablespace_name seg_tablespace_name, 
  blocks,
	header_file hdrfil,
	HEADER_BLOCK hdrblk
from 
	dba_segments 
where 
	upper(segment_name) LIKE 
				upper(CASE 
					WHEN INSTR('&1','.') > 0 THEN 
					    SUBSTR('&1',INSTR('&1','.')+1)
					ELSE
					    '&1'
					END
				     )
AND	owner LIKE
		CASE WHEN INSTR('&1','.') > 0 THEN
			UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
		ELSE
			user
		END
/

