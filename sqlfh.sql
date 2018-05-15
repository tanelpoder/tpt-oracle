-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   sqlfh.sql (SQL Feature Hieararchy)
--
-- Purpose:     Display the full SQL Feature Hieararchy from v$sql_feature
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @sqlfh
--          
-- Other:       Requires Oracle 11g+
--
--------------------------------------------------------------------------------

COL sqlfh_feature HEAD SQL_FEATURE FOR A55

PROMPT Display full SQL Feature Hierarchy from v$sql_feature ...
SELECT 
    LPAD(' ', (level-1)*2) || REPLACE(f.sql_feature, 'QKSFM_','') sqlfh_feature
  , f.description 
FROM 
    v$sql_feature f
  , v$sql_feature_hierarchy fh 
WHERE 
    f.sql_feature = fh.sql_feature 
CONNECT BY fh.parent_id = PRIOR f.sql_Feature 
START WITH fh.sql_feature = 'QKSFM_ALL'
/

