-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- monitor shared pool activity, free memory and chunk flushing
--
-- USAGE: 
--   exec shared_pool_monitor.get_all( <sampling_interval>, <how_many_samples )
-- 
-- exec shared_pool_monitor.get_all  -- this will sample every 10 minutes, forever


CREATE OR REPLACE PACKAGE shared_pool_monitor AS
    PROCEDURE get_subpool_stats          (p_date IN DATE DEFAULT SYSDATE);
    PROCEDURE get_flush_stats            (p_date IN DATE DEFAULT SYSDATE);
    PROCEDURE get_heap_activity_stats    (p_date IN DATE DEFAULT SYSDATE);    
    PROCEDURE get_reserved_chunk_stats   (p_date IN DATE DEFAULT SYSDATE);
    PROCEDURE get_reserved_chunk_details (p_date IN DATE DEFAULT SYSDATE);
    PROCEDURE get_all                    (p_sleep IN NUMBER DEFAULT 600, p_times IN NUMBER DEFAULT 0);
END shared_pool_monitor;
/
SHOW ERR

CREATE OR REPLACE PACKAGE BODY shared_pool_monitor AS

    PROCEDURE get_subpool_stats(p_date IN DATE DEFAULT SYSDATE) AS
    BEGIN
        DBMS_APPLICATION_INFO.SET_ACTION('GET_SUBPOOL_STATS:BEGIN');

        INSERT INTO spmon_subpool_stats (sample_time,subpool,name,bytes)
        SELECT
            SYSDATE
          , ksmdsidx
          , ksmssnam
          , SUM(ksmsslen)
        FROM
            x$ksmss
        WHERE
            ksmsslen > 0
        AND ksmdsidx > 0
        GROUP BY
            SYSDATE
          , ksmdsidx
          , ksmssnam;

        COMMIT;  
 
        DBMS_APPLICATION_INFO.SET_ACTION('GET_SUBPOOL_STATS:END');
    END get_subpool_stats;

    PROCEDURE get_flush_stats(p_date IN DATE DEFAULT SYSDATE) AS
    BEGIN
        DBMS_APPLICATION_INFO.SET_ACTION('GET_FLUSH_STATS:BEGIN');

        -- this procedure relies on the fact that X$KSMLRU contents are cleared out
        -- automatically every time it's queried
        INSERT INTO spmon_flush_stats ( sample_time, addr, indx, inst_id, chunk_subpool
                                       , chunk_duration, chunk_comment , chunk_size 
                                       , chunks_flushed_out , flusher_object_name 
                                       , flusher_hash_value , flusher_ses_addr )
        SELECT
            p_date sample_time
          , ADDR    
          , INDX    
          , INST_ID 
          , KSMLRIDX
          , KSMLRDUR
          , KSMLRCOM
          , KSMLRSIZ
          , KSMLRNUM
          , KSMLRHON
          , KSMLROHV
          , KSMLRSES
        FROM
            x$ksmlru
        WHERE
            ksmlrnum > 0;

        COMMIT;

        DBMS_APPLICATION_INFO.SET_ACTION('GET_FLUSH_STATS:END');
    END get_flush_stats;

    PROCEDURE get_heap_activity_stats(p_date IN DATE DEFAULT SYSDATE) AS
    BEGIN
        DBMS_APPLICATION_INFO.SET_ACTION('GET_HEAP_ACTIVITY_STATS:BEGIN');

        INSERT INTO spmon_heap_activity_stats
        SELECT
            p_date
          , kghluidx
          , kghludur
          , kghlufsh
          , kghluops
          , kghlurcr
          , kghlutrn
          , kghlunfu
          , kghlunfs
          , kghlumxa
          , kghlumes
          , kghlumer
          , kghlurcn
          , kghlurmi
          , kghlurmz
          , kghlurmx
        FROM
            x$kghlu;
        COMMIT;

        DBMS_APPLICATION_INFO.SET_ACTION('GET_HEAP_ACTIVITY_STATS:END');
    END get_heap_activity_stats;

    PROCEDURE get_reserved_chunk_details(p_date IN DATE DEFAULT SYSDATE) AS
    BEGIN
        DBMS_APPLICATION_INFO.SET_ACTION('GET_RESERVED_CHUNKS:BEGIN');
        INSERT INTO spmon_reserved_chunk_details
        SELECT
            p_date
          , ADDR    
          , INDX    
          , INST_ID 
          , KSMCHCOM
          , KSMCHPTR
          , KSMCHSIZ
          , KSMCHCLS
          , KSMCHTYP
          , KSMCHPAR
        FROM
            x$ksmspr -- important, this view must be x$ksmspR <-- (not the x$ksmsp which may hang your instance)
        ;
        COMMIT;
        DBMS_APPLICATION_INFO.SET_ACTION('GET_RESERVED_CHUNKS:END');
    END get_reserved_chunk_details;


    PROCEDURE get_reserved_chunk_stats(p_date IN DATE DEFAULT SYSDATE) AS
    BEGIN
        DBMS_APPLICATION_INFO.SET_ACTION('GET_RESERVED_CHUNKS:BEGIN');
        INSERT INTO spmon_reserved_chunk_stats
        SELECT
            p_date
          , KSMCHCLS
          , KSMCHCOM
          , KSMCHTYP
          , COUNT(*)
          , SUM(KSMCHSIZ)
          , AVG(KSMCHSIZ)
          , MIN(KSMCHSIZ)
          , MAX(KSMCHSIZ)
        FROM
            x$ksmspr -- important, this view must be x$ksmspR <-- (not the x$ksmsp which may hang your instance)
        GROUP BY
            p_date
          , ksmchcls
          , ksmchcom
          , ksmchtyp;

        COMMIT;
        DBMS_APPLICATION_INFO.SET_ACTION('GET_RESERVED_CHUNKS:END');
    END get_reserved_chunk_stats;



    PROCEDURE get_all(p_sleep IN NUMBER DEFAULT 600, p_times IN NUMBER DEFAULT 0) AS
        cur_date DATE;
    BEGIN

        IF p_times > 0 THEN -- sample x times
            FOR i IN 1..p_times LOOP
                cur_date := SYSDATE;

                get_subpool_stats(cur_date);
                get_heap_activity_stats(cur_date);
                get_flush_stats(cur_date);
                get_reserved_chunk_stats(cur_date);

                DBMS_APPLICATION_INFO.SET_ACTION('MAIN LOOP:SLEEPING');
                DBMS_LOCK.SLEEP(p_sleep);
            END LOOP; -- 1..p_times
        ELSE -- sample forever
            WHILE TRUE LOOP
                cur_date := SYSDATE;

                get_subpool_stats(cur_date);
                get_heap_activity_stats(cur_date);
                get_flush_stats(cur_date);
                get_reserved_chunk_stats(cur_date);

                DBMS_APPLICATION_INFO.SET_ACTION('MAIN LOOP:SLEEPING');
                DBMS_LOCK.SLEEP(p_sleep);
            END LOOP; -- while true
        END IF; -- p_times > 0 

    END get_all;

BEGIN
    DBMS_APPLICATION_INFO.SET_MODULE('SHARED POOL MONITOR', 'PACKAGE INITIALIZATION');

END shared_pool_monitor;
/

SHOW ERR

GRANT EXECUTE ON shared_pool_monitor TO perfstat;

