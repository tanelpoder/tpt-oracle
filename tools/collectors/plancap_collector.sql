-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

CREATE OR REPLACE PACKAGE plancap_collector AS

    PROCEDURE snap_data_files;
    PROCEDURE snap_free_space;
    PROCEDURE snap_segment_space;
    PROCEDURE snap_service_stats;

END plancap_collector;
/

CREATE OR REPLACE PACKAGE BODY plancap_collector AS

    PROCEDURE snap_data_files AS
    BEGIN
        INSERT INTO plancap$data_files
        SELECT 
            sysdate 
          , tablespace_name
          , file_id
          , SUM(bytes)
          , SUM(blocks)
          , relative_fno
        FROM
            dba_data_files
        GROUP BY
            sysdate, tablespace_name, file_id, relative_fno;
        COMMIT;
    END snap_data_files;

    PROCEDURE snap_free_space AS
    BEGIN
        INSERT INTO plancap$free_space
        SELECT 
            sysdate 
          , tablespace_name
          , file_id
          , SUM(bytes)
          , SUM(blocks)
          , relative_fno
        FROM
            dba_free_space
        GROUP BY
            sysdate, tablespace_name, file_id, relative_fno;
        COMMIT;
    END snap_free_space;

    PROCEDURE snap_segment_space AS
    BEGIN
        INSERT INTO plancap$segment_space
        SELECT 
            sysdate 
          , owner          
          , segment_name   
          , NVL(partition_name,'-') partition_name 
          , segment_type
          , tablespace_name   
          , SUM(bytes)   bytes        
          , SUM(blocks)  blocks  
          , SUM(extents) extents       
        FROM
            dba_segments
        GROUP BY
            sysdate, owner, segment_name, NVL(partition_name,'-'), tablespace_name, segment_type;
        COMMIT;
    END snap_segment_space;


    PROCEDURE snap_service_stats AS
    BEGIN
        INSERT INTO plancap$service_stats
        WITH sq AS (
            SELECT service_name,stat_name,value FROM v$service_stats
        )
        SELECT
            sysdate
          , a.service_name
          , a.value DB_CPU
          , b.value EXECUTE_COUNT
          , c.value USER_COMMITS
          , d.value USER_CALLS
        FROM
            sq a
          , sq b
          , sq c
          , sq d
        WHERE
            a.service_name = b.service_name
        AND b.service_name = c.service_name
        AND c.service_name = d.service_name
        AND a.stat_name = 'DB CPU'
        AND b.stat_name = 'execute count'
        AND c.stat_name = 'user commits'
        AND d.stat_name = 'user calls';
        COMMIT;
    END;


END plancap_collector;
/

SHOW ERR




   