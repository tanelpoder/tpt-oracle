-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL imseg_owner FOR A20
COL imseg_segment_name FOR A30
COL imseg_partition_name FOR A30
COL imseg_pct_done HEAD '%POP' FOR A5 JUST RIGHT

COMPUTE SUM LABEL 'totseg' OF seg_mb ON seg_mb REPORT
COMPUTE SUM LABEL 'totmem' OF inmem_mb ON inmem_mb REPORT
COMPUTE SUM LABEL 'totnot' OF mb_notpop ON mb_notpop REPORT

BREAK ON REPORT

SELECT
    ROUND(SUM(bytes)/1048576) seg_MB   -- dont want to double count the segment size from gv$
  , ROUND(SUM(inmemory_size)/1048576) inmem_MB 
  , LPAD(ROUND((1-(SUM(bytes_not_populated)/NULLIF(SUM(bytes),0)))*100)||'%',5) imseg_pct_done
--  , LPAD(ROUND(SUM(inmemory_size)/SUM(bytes)*100)||'%',5) compr_pct
  , owner imseg_owner
  , segment_name imseg_segment_name
--  , partition_name imseg_partition_name
  , segment_type        
  , COUNT(DISTINCT partition_name) partitions
  , tablespace_name     
  , inst_id
  , populate_status       pop_status
  , inmemory_priority     im_priority
  , inmemory_distribute   im_distribute
  , inmemory_compression  im_compression
  , con_id   
  , inst_id           
FROM 
    gv$im_segments
WHERE
  upper(segment_name) LIKE
        upper(CASE
          WHEN INSTR('&1','.') > 0 THEN
              SUBSTR('&1',INSTR('&1','.')+1)
          ELSE
              '&1'
          END
             )
AND owner LIKE
    CASE WHEN INSTR('&1','.') > 0 THEN
      UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
    ELSE
      user
    END
GROUP BY 
    owner  -- imseg_owner 
  , segment_name -- imseg_segment_name
--  , partition_name -- imseg_partition_name
  , segment_type        
  , tablespace_name 
  , inst_id    
  , populate_status     
  , inmemory_priority   
  , inmemory_distribute 
  , inmemory_compression
  , con_id    
  , inst_id  
ORDER BY
    inmem_mb DESC
/

CLEAR BREAKS
