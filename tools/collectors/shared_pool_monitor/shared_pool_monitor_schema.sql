-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- change to whichever tablespace you want to create these tables in
DEF tablespace=TOOLS

-- x$ksmss (v$sgastat)
CREATE TABLE spmon_subpool_stats ( 
    sample_time           DATE
  , subpool               NUMBER
  , name                  VARCHAR2(100)
  , bytes                 NUMBER
)
TABLESPACE &tablespace STORAGE (INITIAL 1M NEXT 10M PCTINCREASE 0);

-- x$ksmlru 
CREATE TABLE spmon_flush_stats (
    sample_time           DATE
  , addr                  RAW(8)
  , indx                  NUMBER
  , inst_id               NUMBER
  , chunk_subpool         NUMBER
  , chunk_duration        NUMBER
  , chunk_comment         VARCHAR2(100)
  , chunk_size            NUMBER
  , chunks_flushed_out    NUMBER
  , flusher_object_name   VARCHAR2(100)
  , flusher_hash_value    NUMBER
  , flusher_ses_addr      RAW(8)
)
TABLESPACE &tablespace STORAGE (INITIAL 1M NEXT 10M PCTINCREASE 0);

-- x$kghlu (part of v$shared_pool_reserved)
CREATE TABLE spmon_heap_activity_stats (
    sample_time           DATE
  , kghluidx              NUMBER -- subpool id
  , kghludur              NUMBER -- allocation duration class
  , kghlufsh              NUMBER -- chunks flushed
  , kghluops              NUMBER -- LRU operations (moving chunks around in LRU list)
  , kghlurcr              NUMBER -- recurrent chunks (pinned/unpinned 3 times or more)
  , kghlutrn              NUMBER -- transient chunks (pinned 1-2 times)
  , kghlumxa              NUMBER -- 
  , kghlumes              NUMBER --
  , kghlumer              NUMBER -- 
  , kghlurcn              NUMBER -- reserved freelist scans
  , kghlurmi              NUMBER -- reserved freelist misses
  , kghlurmz              NUMBER -- last reserved scan miss size
  , kghlurmx              NUMBER -- reserved list scan max miss size
  , kghlunfu              NUMBER -- number of free-unpinned unsuccessful attempts
  , kghlunfs              NUMBER -- last free unpinned unsuccessful size
)
TABLESPACE &tablespace STORAGE (INITIAL 1M NEXT 10M PCTINCREASE 0);

CREATE OR REPLACE VIEW spmon_heap_activity_view AS
SELECT
    sample_time
  , kghluidx  subpool
  , kghludur  duration
  , CASE WHEN kghlufsh - NVL(lag(kghlufsh,1) over (partition by kghluidx, kghludur order by sample_time), kghlufsh) < 0 
      THEN kghlufsh
    ELSE kghlufsh - lag(kghlufsh,1) over (partition by kghluidx, kghludur order by sample_time)
    END flushed_chunks_d
  , CASE WHEN kghluops - NVL(lag(kghluops,1) over (partition by kghluidx, kghludur order by sample_time), kghluops) < 0 
      THEN kghluops
    ELSE kghluops - lag(kghluops,1) over (partition by kghluidx, kghludur order by sample_time)
    END lru_operations_d
  , CASE WHEN kghlurcn - NVL(lag(kghlurcn,1) over (partition by kghluidx, kghludur order by sample_time), kghlurcn) < 0 
      THEN kghlurcn
    ELSE kghlurcn - lag(kghlurcn,1) over (partition by kghluidx, kghludur order by sample_time)
    END reserved_scans
  , CASE WHEN kghlurmi - NVL(lag(kghlurmi,1) over (partition by kghluidx, kghludur order by sample_time), kghlurmi) < 0 
      THEN kghlurmi
    ELSE kghlurmi - lag(kghlurmi,1) over (partition by kghluidx, kghludur order by sample_time)
    END reserved_misses
  , CASE WHEN kghlunfu - NVL(lag(kghlunfu,1) over (partition by kghluidx, kghludur order by sample_time), kghlunfu) < 0 
      THEN kghlunfu
    ELSE kghlunfu - lag(kghlunfu,1) over (partition by kghluidx, kghludur order by sample_time)
    END unsuccessful_flushes
  , kghlurmz last_unsucc_miss_req_size
  , kghlunfs last_unsucc_flush_req_size
FROM
    spmon_heap_activity_stats
/

-- chunk details (all chunks in reserved area are dumped here)
-- x$ksmspr (v$shared_pool_reserved)
CREATE TABLE spmon_reserved_chunk_details (
    sample_time           DATE
  , addr                  RAW(8)
  , indx                  NUMBER
  , inst_id               NUMBER
  , ksmchcom              VARCHAR2(100)
  , ksmchptr              RAW(8)
  , ksmchsiz              NUMBER
  , ksmchcls              VARCHAR2(100)
  , ksmchtyp              NUMBER
  , ksmchpar              RAW(8)
)
TABLESPACE &tablespace STORAGE (INITIAL 1M NEXT 10M PCTINCREASE 0);

-- min,max,avg chunk size grouped by chunk type and (allocation reason) comment
-- x$ksmspr (v$shared_pool_reserved) summary
CREATE TABLE spmon_reserved_chunk_stats (
    sample_time           DATE
  , ksmchcls              VARCHAR2(100)
  , ksmchcom              VARCHAR2(100)
  , ksmchtype             NUMBER
  , chunk_count           NUMBER
  , total_size            NUMBER
  , avg_size              NUMBER
  , min_size              NUMBER
  , max_size              NUMBER
)
TABLESPACE &tablespace STORAGE (INITIAL 1M NEXT 10M PCTINCREASE 0);

GRANT SELECT ON SPMON_FLUSH_STATS                 TO PERFSTAT;
GRANT SELECT ON SPMON_HEAP_ACTIVITY_STATS         TO PERFSTAT; 
GRANT SELECT ON SPMON_RESERVED_CHUNK_DETAILS      TO PERFSTAT;
GRANT SELECT ON SPMON_RESERVED_CHUNK_STATS        TO PERFSTAT;
GRANT SELECT ON SPMON_SUBPOOL_STATS               TO PERFSTAT;

GRANT SELECT ON spmon_heap_activity_view          TO PERFSTAT;


