-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column owner           format a15         heading "Owner"
column segment_name    format a50         heading "Object"
column tablespace_name format a30         heading "Tablespace"
column next_extent     format 9G999G999   heading "Next (K)"
column max_free        format 999G999G999 heading "Max Free (K)"

prompt
select /*+ ordered */ 
       s.owner,
       s.segment_name||decode(s.partition_name,NULL,'','.'||s.partition_name)
          segment_name,
       s.tablespace_name, s.next_extent/1024 next_extent,
       f.max_free/1024 max_free
from ( select /*+ ordered */ 
              s.owner, s.segment_name, s.partition_name, s.tablespace_name, 
       decode(t.allocation_type,
              'SYSTEM',decode(sign(s.bytes-1024*1024),-1,64*1024,
                       decode(sign(s.bytes-64*1024*1024),-1,1024*1024,
                       decode(sign(s.bytes-1024*1024*1024),-1,8*1024*1024,
                       64*1024*1024))),
              s.next_extent) next_extent, s.extents, s.max_extents
       from dba_segments s, dba_tablespaces t
       where t.tablespace_name = s.tablespace_name
         and t.contents != 'UNDO' ) s,
     ( select /*+ ordered */ 
              t.tablespace_name, nvl(max(f.bytes),0) max_free 
       from dba_tablespaces t, dba_free_space f
       where f.tablespace_name (+) = t.tablespace_name
       group by t.tablespace_name ) f
where f.tablespace_name = s.tablespace_name
  and f.max_free < s.next_extent
order by 1, 2, 3
/


column owner           format a15         heading "Owner"
column segment_name    format a30         heading "Object"
column tablespace_name format a30         heading "Tablespace"
column extents         format 999G999     heading "Extents"
column max_extents     format a10         heading "Max Extents"
column next_extent     format 9G999G999   heading "Next (K)"
column max_free        format 999G999G999 heading "Max Free (K)"
column quota           format a10         heading " Quota (K)"
def nolimit = ' Unlimited'

prompt
select /*+ ordered */ 
       s.owner,
       s.segment_name||decode(s.partition_name,NULL,'','.'||s.partition_name)
          segment_name,
       s.tablespace_name, s.next_extent/1024 next_extent,
       f.max_free/1024 max_free, s.extents,
       decode (s.max_extents, 2147483645, '&nolimit',
               to_char(s.max_extents, '9G999G999')) max_extents,
       decode (p.privilege, NULL, 
                            decode(nvl(q.max_bytes,decode(s.owner,'SYS',-1,0)),
                                   -1, '&nolimit',
                                   to_char(nvl(q.max_bytes,0)/1024,'9G999G999')),
               '&nolimit') quota
from ( select /*+ ordered */ 
              s.owner, s.segment_name, s.partition_name, s.tablespace_name, 
       decode(t.allocation_type,
              'SYSTEM',decode(sign(s.bytes-1024*1024),-1,64*1024,
                       decode(sign(s.bytes-64*1024*1024),-1,1024*1024,
                       decode(sign(s.bytes-1024*1024*1024),-1,8*1024*1024,
                       64*1024*1024))),
              s.next_extent) next_extent, s.extents, s.max_extents
       from dba_segments s, dba_tablespaces t
       where t.tablespace_name = s.tablespace_name
         and t.contents != 'UNDO' ) s,
     ( select /*+ ordered */ 
              t.tablespace_name, nvl(max(f.bytes),0) max_free 
       from dba_tablespaces t, dba_free_space f
       where f.tablespace_name (+) = t.tablespace_name
       group by t.tablespace_name ) f,
     dba_sys_privs p, dba_ts_quotas q
where q.username (+) = s.owner
  and q.tablespace_name (+) = s.tablespace_name
  and p.grantee (+) = s.owner
  and p.privilege (+) = 'UNLIMITED TABLESPACE'
  and f.tablespace_name = s.tablespace_name
  and f.max_free < s.next_extent
order by 1, 2, 3
/
