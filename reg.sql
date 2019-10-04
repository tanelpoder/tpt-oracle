-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL action_time FOR A30

PROMPT Querying DBA_REGISTRY_HISTORY ...
--SELECT action_time, bundle_series, comments FROM dba_registry_history ORDER BY action_time ASC;
SELECT * FROM dba_registry_history ORDER BY action_time ASC;
SELECT
    action_time                     
--  install_id 
  , patch_id   
  , patch_uid  
  , patch_type 
  , action                          -- not present in 12c
  , status                          
  , description                     
--, logfile                         
--, ru_logfile                      
--, patch_descriptor                --          sys.xmltype
--, source_version                  
--, source_build_description        
--, source_build_timestamp          
--, target_version                  
--, target_build_description        
--, target_build_timestamp          
FROM dba_registry_sqlpatch ORDER BY action_time ASC;
