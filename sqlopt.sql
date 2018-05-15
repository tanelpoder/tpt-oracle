-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL sqlopt_hash_value HEAD HASH_VALUE
COL sqlopt_sqlid HEAD SQL_ID
COL sqlopt_child# HEAD CHILD#

BREAK ON sqlopt_hash_value SKIP 1 ON sqlopt_sqlid SKIP 1 ON sqlopt_child# SKIP 1

PROMPT Show compilation environment stored inside cursors for SQLID &1 child# &2 parameter &3

SELECT 
--    inst_id
--  , kqlfsqce_phad
    kqlfsqce_hash           sqlopt_hash_value
  , kqlfsqce_sqlid          sqlopt_sqlid
  , kqlfsqce_chno           sqlopt_child#
--  , kqlfsqce_hadd
--  , kqlfsqce_pnum
  , kqlfsqce_pname          parameter
  , UPPER(kqlfsqce_pvalue)  value                                         
  , DECODE(BITAND(kqlfsqce_flags, 2), 0, 'NO', 'YES') "DFLT"
FROM -- v$sql_optimizer_env
    x$kqlfsqce 
WHERE 
    kqlfsqce_sqlid LIKE '&1'
AND kqlfsqce_chno  LIKE ('&2')
AND LOWER(kqlfsqce_pname) LIKE LOWER('%&3%')
ORDER BY
    kqlfsqce_hash
  , kqlfsqce_sqlid
  , kqlfsqce_chno
  , kqlfsqce_pname
/
