-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINES 10000 PAGES 5000 TRIMSPOOL ON TRIMOUT ON TAB OFF

COL nonsharedsum_sqlid HEAD SQL_ID

BREAK ON nonsharedsum_sqlid SKIP 1

DEF _CURSOR_COUNT=2

WITH raw_data AS (
    SELECT /*+ MATERIALIZE */ * FROM v$sql_shared_cursor
    WHERE sql_id IN (
        SELECT sql_id FROM v$sql GROUP BY sql_id HAVING COUNT(*) > &_CURSOR_COUNT
    )
),
sq AS (  
    SELECT sql_id, why, CASE WHEN child_cursors = 'Y' THEN 1 ELSE 0 END child_count
    FROM raw_data 
    UNPIVOT (
      child_cursors FOR why IN (
           UNBOUND_CURSOR                                   
         , SQL_TYPE_MISMATCH                                  
         , OPTIMIZER_MISMATCH                                 
         , OUTLINE_MISMATCH                                   
         , STATS_ROW_MISMATCH                                 
         , LITERAL_MISMATCH                                   
         , FORCE_HARD_PARSE                                   
         , EXPLAIN_PLAN_CURSOR                                
         , BUFFERED_DML_MISMATCH                              
         , PDML_ENV_MISMATCH                                  
         , INST_DRTLD_MISMATCH                                
         , SLAVE_QC_MISMATCH                                  
         , TYPECHECK_MISMATCH                                 
         , AUTH_CHECK_MISMATCH                                
         , BIND_MISMATCH                                      
         , DESCRIBE_MISMATCH                                  
         , LANGUAGE_MISMATCH                                  
         , TRANSLATION_MISMATCH                               
         --, ROW_LEVEL_SEC_MISMATCH                             
         , INSUFF_PRIVS                                       
         , INSUFF_PRIVS_REM                                   
         , REMOTE_TRANS_MISMATCH                              
         , LOGMINER_SESSION_MISMATCH                          
         , INCOMP_LTRL_MISMATCH                               
         , OVERLAP_TIME_MISMATCH                              
         , EDITION_MISMATCH                                   
         , MV_QUERY_GEN_MISMATCH                              
         , USER_BIND_PEEK_MISMATCH                            
         , TYPCHK_DEP_MISMATCH                                
         , NO_TRIGGER_MISMATCH                                
         , FLASHBACK_CURSOR                                   
         , ANYDATA_TRANSFORMATION                             
         -- , INCOMPLETE_CURSOR                                  
         , TOP_LEVEL_RPI_CURSOR                               
         , DIFFERENT_LONG_LENGTH                              
         , LOGICAL_STANDBY_APPLY                              
         , DIFF_CALL_DURN                                     
         , BIND_UACS_DIFF                                     
         , PLSQL_CMP_SWITCHS_DIFF                             
         , CURSOR_PARTS_MISMATCH                              
         , STB_OBJECT_MISMATCH                                
         , CROSSEDITION_TRIGGER_MISMATCH                      
         , PQ_SLAVE_MISMATCH                                  
         , TOP_LEVEL_DDL_MISMATCH                             
         , MULTI_PX_MISMATCH                                  
         , BIND_PEEKED_PQ_MISMATCH                            
         , MV_REWRITE_MISMATCH                                
         , ROLL_INVALID_MISMATCH                              
         , OPTIMIZER_MODE_MISMATCH                            
         , PX_MISMATCH                                        
         , MV_STALEOBJ_MISMATCH                               
         , FLASHBACK_TABLE_MISMATCH                           
         , LITREP_COMP_MISMATCH                               
         , PLSQL_DEBUG                                        
         , LOAD_OPTIMIZER_STATS                               
         , ACL_MISMATCH                                       
         , FLASHBACK_ARCHIVE_MISMATCH                         
         , LOCK_USER_SCHEMA_FAILED                            
         , REMOTE_MAPPING_MISMATCH                            
         , LOAD_RUNTIME_HEAP_FAILED                           
         , HASH_MATCH_FAILED                                  
        )
    )
)
SELECT
    sql_id nonsharedsum_sqlid
  , why
  , child_count
FROM sq
WHERE
    child_count > 0
/ 
