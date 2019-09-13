-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Compare Optimizer Features Enable Fix values - find fixes that are not affected by optimizer_features_enable setting
-- 
-- By Tanel Poder ( https://blog.tanelpoder.com )
--   Requires opt_param_matrix table to be created (using tools/optimizer/optimizer_features_matrix.sql)
--   Requires Oracle 11g+ due to PIVOT clause (but you can rewrite this SQL in earlier versions)`

COL sql_feature FOR a40

-- funky pivot formatting for sqlplus

COL "'18.1.0'" FOR A30 WRAP
COL "'8.0.0'" FOR A30 WRAP
COL "'8.0.3'" FOR A30 WRAP
COL "'8.0.4'" FOR A30 WRAP
COL "'8.0.5'" FOR A30 WRAP
COL "'8.0.6'" FOR A30 WRAP
COL "'8.0.7'" FOR A30 WRAP
COL "'8.1.0'" FOR A30 WRAP
COL "'8.1.3'" FOR A30 WRAP
COL "'8.1.4'" FOR A30 WRAP
COL "'8.1.5'" FOR A30 WRAP
COL "'8.1.6'" FOR A30 WRAP
COL "'8.1.7'" FOR A30 WRAP
COL "'9.0.0'" FOR A30 WRAP
COL "'9.0.1'" FOR A30 WRAP
COL "'9.2.0'" FOR A30 WRAP
COL "'9.2.0.8'" FOR A30 WRAP
COL "'10.1.0'" FOR A30 WRAP
COL "'10.1.0.3'" FOR A30 WRAP
COL "'10.1.0.4'" FOR A30 WRAP
COL "'10.1.0.5'" FOR A30 WRAP
COL "'10.2.0.1'" FOR A30 WRAP
COL "'10.2.0.2'" FOR A30 WRAP
COL "'10.2.0.3'" FOR A30 WRAP
COL "'10.2.0.4'" FOR A30 WRAP
COL "'10.2.0.5'" FOR A30 WRAP
COL "'11.1.0.6'" FOR A30 WRAP
COL "'11.1.0.7'" FOR A30 WRAP
COL "'11.2.0.1'" FOR A30 WRAP
COL "'11.2.0.2'" FOR A30 WRAP
COL "'11.2.0.3'" FOR A30 WRAP
COL "'11.2.0.4'" FOR A30 WRAP
COL "'12.1.0.1'" FOR A30 WRAP
COL "'12.1.0.2'" FOR A30 WRAP
COL "'12.2.0.1'" FOR A30 WRAP
COL "'18.1.0.1'" FOR A30 WRAP


prompt Compare Optimizer_Features_Enable Fix differences 
prompt for values &1 and &2 (v$session_fix_control)
prompt

COL cofef_min NEW_VALUE cofef_min
COL cofef_max NEW_VALUE cofef_max

SET TERMOUT OFF
WITH sq AS (
    SELECT ordinal, name, value FROM v$parameter_valid_values WHERE name = 'optimizer_features_enable'
)
SELECT 
    (SELECT value FROM sq WHERE ordinal = (SELECT MIN(ordinal) FROM sq)) cofef_min
  , (SELECT value FROM sq WHERE ordinal = (SELECT MAX(ordinal) FROM sq)) cofef_max
FROM
    dual
/
SET TERMOUT ON

WITH sq AS (
    SELECT /*+ MATERIALIZE */ bugno
    FROM 
        opt_fix_matrix 
      PIVOT( 
        MAX(SUBSTR(value,1,20)) 
        FOR opt_features_enabled IN ('&cofef_min' , '&cofef_max')
      ) 
    WHERE
        "'&cofef_min'" != "'&cofef_max'"
)
SELECT 
    *
FROM
    v$session_fix_control
WHERE
    session_id = SYS_CONTEXT('userenv', 'sid')
AND bugno NOT IN (
    SELECT bugno FROM sq
)
/

