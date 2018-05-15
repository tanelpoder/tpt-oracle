-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col o_owner heading owner for a25
col o_object_name heading OBJECT_NAME for a30
col o_subobject_name heading SUBOBJECT_NAME FOR a30
col o_object_type heading OBJECT_TYPE for a18
col o_status heading STATUS for a9

prompt Display number of buffered blocks of a segment using X$KCBOQH for table &1

-- done: currently buggy when data object ID doesn't match object Id (due to truncate or alter table move / rebuild)
select * from (
    select 
        SUM(x.num_buf) num_buf,
        ROUND(SUM(x.num_buf * ts.blocksize) / 1024 / 1024 , 2)  mb_buf,
        o.owner o_owner,
        o.object_name o_object_name, 
        o.subobject_name o_subobject_name,
        ts.name tablespace_name,
        o.object_type o_object_type,
        o.status o_status,
        o.object_id oid,
        o.data_object_id d_oid,
        o.created, 
        o.last_ddl_time
    from 
        dba_objects o
      , x$kcboqh x
      , dba_segments s
    --  , sys_objects so
      , ts$ ts
    where 
        x.obj# = o.data_object_id
    --and o.data_object_id = so.object_id
    and o.owner = s.owner
    and o.object_name = s.segment_name
    and SYS_OP_MAP_NONNULL(o.subobject_name) = SYS_OP_MAP_NONNULL(s.partition_name)
    and s.tablespace_name = ts.name
    --and x.ts# = ts.ts#
    and
    	upper(object_name) LIKE 
    				upper(CASE 
    					WHEN INSTR('&1','.') > 0 THEN 
    					    SUBSTR('&1',INSTR('&1','.')+1)
    					ELSE
    					    '&1'
    					END
    				     )
    AND	o.owner LIKE
    		CASE WHEN INSTR('&1','.') > 0 THEN
    			UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
    		ELSE
    			user
    		END
    group by
        o.owner 
      , o.object_name 
      , o.subobject_name
      , ts.name
      , o.object_type
      , o.status
      , o.object_id 
      , data_object_id
      , o.created 
      , o.last_ddl_time
    order by 
        num_buf desc
    --    o_object_name,
    --    o_owner,
    --    o_object_type
)
where
    rownum <= 20
/
