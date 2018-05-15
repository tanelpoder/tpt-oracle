-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col bhla_object head object for a40 truncate
col bhla_DBA head DBA for a20
col flg_lruflg head "FLAG:LRUFLAG"

select  /*+ ORDERED */
	trim(to_char(bh.flag, 'XXXXXXXX'))	||':'||
	trim(to_char(bh.lru_flag, 'XXXXXXXX')) 	flg_lruflg,
	bh.obj,
	o.object_type,
	o.owner||'.'||o.object_name		bhla_object,
	bh.tch,
	file# ||' '||dbablk			bhla_DBA,
	bh.class,
	bh.state,
	bh.mode_held,
	bh.dirty_queue				DQ
from
	x$bh		bh,
	dba_objects	o
where
	bh.obj = o.data_object_id
and	bitand(flag,8)=8
order by
	tch asc
/
