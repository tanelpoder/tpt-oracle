-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

CREATE OR REPLACE VIEW t$ash AS
SELECT
    SAMPLE_ID                               --  NUMBER
  , CAST(SAMPLE_TIME AS DATE)     sample_time   --  TIMESTAMP(3)
  , TO_CHAR(sample_time, 'YYYY')  sample_year
  , TO_CHAR(sample_time, 'MM')    sample_month_num
  , TO_CHAR(sample_time, 'MON')   sample_mon
  , TO_CHAR(sample_time, 'Month') sample_month
  , TO_CHAR(sample_time, 'DD')    sample_day
  , TO_CHAR(sample_time, 'HH24')  sample_hour
  , TO_CHAR(sample_time, 'MI')    sample_minute
  , TO_CHAR(sample_time, 'SS')    sample_second
  , IS_AWR_SAMPLE                           --  VARCHAR2(1)
  , SESSION_ID                              --  NUMBER
  , SESSION_SERIAL#                         --  NUMBER
  , SESSION_TYPE                            --  VARCHAR2(10)
  , FLAGS                                   --  NUMBER
  , a.USER_ID                                 --  NUMBER
  , u.username
  , SQL_ID                                  --  VARCHAR2(13)
  , IS_SQLID_CURRENT                        --  VARCHAR2(1)
  , SQL_CHILD_NUMBER                        --  NUMBER
  , SQL_OPCODE                              --  NUMBER
  , SQL_OPNAME                              --  VARCHAR2(64)
  , FORCE_MATCHING_SIGNATURE                --  NUMBER
  , TOP_LEVEL_SQL_ID                        --  VARCHAR2(13)
  , TOP_LEVEL_SQL_OPCODE                    --  NUMBER
  , SQL_PLAN_HASH_VALUE                     --  NUMBER
  , SQL_PLAN_LINE_ID                        --  NUMBER
  , SQL_PLAN_OPERATION                      --  VARCHAR2(30)
  , SQL_PLAN_OPTIONS                        --  VARCHAR2(30)
  , SQL_EXEC_ID                             --  NUMBER
  , SQL_EXEC_START                          --  DATE
  , PLSQL_ENTRY_OBJECT_ID                   --  NUMBER
  , PLSQL_ENTRY_SUBPROGRAM_ID               --  NUMBER
  , PLSQL_OBJECT_ID                         --  NUMBER
  , PLSQL_SUBPROGRAM_ID                     --  NUMBER
  , QC_INSTANCE_ID                          --  NUMBER
  , QC_SESSION_ID                           --  NUMBER
  , QC_SESSION_SERIAL#                      --  NUMBER
  , PX_FLAGS                                --  NUMBER
  , EVENT                                   --  VARCHAR2(64)
  , EVENT_ID                                --  NUMBER
  , EVENT#                                  --  NUMBER
  , SEQ#                                    --  NUMBER
  , P1TEXT                                  --  VARCHAR2(64)
  , P1                                      --  NUMBER
  , P2TEXT                                  --  VARCHAR2(64)
  , P2                                      --  NUMBER
  , P3TEXT                                  --  VARCHAR2(64)
  , P3                                      --  NUMBER
  , WAIT_CLASS                              --  VARCHAR2(64)
  , WAIT_CLASS_ID                           --  NUMBER
  , WAIT_TIME                               --  NUMBER
  , SESSION_STATE                           --  VARCHAR2(7)
  , TIME_WAITED                             --  NUMBER
  , BLOCKING_SESSION_STATUS                 --  VARCHAR2(11)
  , BLOCKING_SESSION                        --  NUMBER
  , BLOCKING_SESSION_SERIAL#                --  NUMBER
  , BLOCKING_INST_ID                        --  NUMBER
  , BLOCKING_HANGCHAIN_INFO                 --  VARCHAR2(1)
  , CURRENT_OBJ#                            --  NUMBER
  , CURRENT_FILE#                           --  NUMBER
  , CURRENT_BLOCK#                          --  NUMBER
  , CURRENT_ROW#                            --  NUMBER
  , TOP_LEVEL_CALL#                         --  NUMBER
  , TOP_LEVEL_CALL_NAME                     --  VARCHAR2(64)
  , CONSUMER_GROUP_ID                       --  NUMBER
  , XID                                     --  RAW(8)
  , REMOTE_INSTANCE#                        --  NUMBER
  , TIME_MODEL                              --  NUMBER
  , IN_CONNECTION_MGMT                      --  VARCHAR2(1)
  , IN_PARSE                                --  VARCHAR2(1)
  , IN_HARD_PARSE                           --  VARCHAR2(1)
  , IN_SQL_EXECUTION                        --  VARCHAR2(1)
  , IN_PLSQL_EXECUTION                      --  VARCHAR2(1)
  , IN_PLSQL_RPC                            --  VARCHAR2(1)
  , IN_PLSQL_COMPILATION                    --  VARCHAR2(1)
  , IN_JAVA_EXECUTION                       --  VARCHAR2(1)
  , IN_BIND                                 --  VARCHAR2(1)
  , IN_CURSOR_CLOSE                         --  VARCHAR2(1)
  , IN_SEQUENCE_LOAD                        --  VARCHAR2(1)
  , CAPTURE_OVERHEAD                        --  VARCHAR2(1)
  , REPLAY_OVERHEAD                         --  VARCHAR2(1)
  , IS_CAPTURED                             --  VARCHAR2(1)
  , IS_REPLAYED                             --  VARCHAR2(1)
  , SERVICE_HASH                            --  NUMBER
  , PROGRAM                                 --  VARCHAR2(48)
  , MODULE                                  --  VARCHAR2(64)
  , ACTION                                  --  VARCHAR2(64)
  , CLIENT_ID                               --  VARCHAR2(64)
  , MACHINE                                 --  VARCHAR2(64)
  , PORT                                    --  NUMBER
  , ECID                                    --  VARCHAR2(64)
  , DBREPLAY_FILE_ID                        --  NUMBER
  , DBREPLAY_CALL_COUNTER                   --  NUMBER
  , TM_DELTA_TIME                           --  NUMBER
  , TM_DELTA_CPU_TIME                       --  NUMBER
  , TM_DELTA_DB_TIME                        --  NUMBER
  , DELTA_TIME                              --  NUMBER
  , DELTA_READ_IO_REQUESTS                  --  NUMBER
  , DELTA_WRITE_IO_REQUESTS                 --  NUMBER
  , DELTA_READ_IO_BYTES                     --  NUMBER
  , DELTA_WRITE_IO_BYTES                    --  NUMBER
  , DELTA_INTERCONNECT_IO_BYTES             --  NUMBER
  , PGA_ALLOCATED                           --  NUMBER
  , TEMP_SPACE_ALLOCATED                    --  NUMBER
FROM
    v$active_session_history a
--  , dba_users u
WHERE
    a.user_id = u.user_id (+)
/

GRANT SELECT ON t$ash TO public;
CREATE PUBLIC SYNONYM t$ash FOR sys.t$ash;
