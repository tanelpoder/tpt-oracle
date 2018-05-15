-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   dba.sql (version 0.2)
-- Purpose:     Convert Data Block Address (a 6 byte hex number) to file#, block#
--              and find to which segment it belongs
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @dba <data_block_address>
--              @dba 40EB02
-- 	        
--	        
-- Other:       This script also tries to identify the segment into which this
--              block belongs. It first queries X$BH, as if this block is really
--              hot, it should be in buffer cache. Note that you can change this
--              query to use V$BH if you dont have access to X$ tables.
--              If the block is not in buffer cache anymore, then this script
--              can query DBA_EXTENTS next, but this can be a IO intensive operation
--              on some systems, so if X$BH already answers your question, press
--              CTRL+C here.
--
--------------------------------------------------------------------------------

col rfile# new_value v_dba_rfile
col block# new_value v_dba_block
col bigfile_block# new_value v_bigfile_block
col dba_object head object for a40 truncate
col dba_DBA head DBA for a20


select 
	dbms_utility.data_block_address_file(to_number('&1','XXXXXXXXXX')) RFILE#, 
	dbms_utility.data_block_address_block(to_number('&1','XXXXXXXXXX')) BLOCK#,
  TO_NUMBER('&1','XXXXXXXXXX') bigfile_block#,
  '-- alter system dump datafile '||dbms_utility.data_block_address_file(to_number('&1','XXXXXXXXXX'))
  ||' block '||dbms_utility.data_block_address_block(to_number('&1','XXXXXXXXXX')) dump_cmd
from dual;

pause Press enter to find the segment using V$BH (this may take CPU time), CTRL+C to cancel: 

select  /*+ ORDERED */
        decode(bh.state,0,'free',1,'xcur',2,'scur',3,'cr',4,'read',5,'mrec',
             6,'irec',7,'write',8,'pi', 9,'memory',10,'mwrite',
             11,'donated', 12,'protected',13,'securefile', 14,'siop',15,'recckpt'
        ) state,
        decode(bh.class,1,'data block',2,'sort block',3,'save undo block', 
               4,'segment header',5,'save undo header',6,'free list',7,'extent map', 
               8,'1st level bmb',9,'2nd level bmb',10,'3rd level bmb', 11,'bitmap block',
               12,'bitmap index block',13,'file header block',14,'unused', 
               15,'system undo header',16,'system undo block', 17,'undo header',
               18,'undo block'
        ) block_class,
	o.object_type,
	o.owner||'.'||o.object_name		dba_object,
	bh.tch,
	bh.mode_held,
    decode(bitand(bh.flag,1),0, 'N', 'Y')       dirty,
    decode(bitand(bh.flag,16), 0, 'N', 'Y')     temp,
    decode(bitand(bh.flag,1536), 0, 'N', 'Y')   ping,
    decode(bitand(bh.flag,16384), 0, 'N', 'Y')  stale,
    decode(bitand(bh.flag,65536), 0, 'N', 'Y')  direct, 
	trim(to_char(bh.flag, 'XXXXXXXX'))	||':'||
	trim(to_char(bh.lru_flag, 'XXXXXXXX')) 	flg_lruflg,
	bh.dirty_queue				DQ
from
	x$bh		bh,
	dba_objects	o
where
	bh.obj = o.data_object_id
and	(
      (file#  = &v_dba_rfile and  dbablk = &v_dba_block)
    or 
      dbablk = &v_bigfile_block)
order by
	tch asc
/

pause Press enter to query what segment resides there using DBA_EXTENTS (this can be IO intensive), CTRL+C to cancel: 

select owner, segment_name, partition_name, tablespace_name 
from dba_extents
where 
    relative_fno = &v_dba_rfile
and &v_dba_block between block_id and block_id + blocks - 1
union all
select owner, segment_name, partition_name, tablespace_name 
from dba_extents
where 
    &v_bigfile_block between block_id and block_id + blocks - 1
/
