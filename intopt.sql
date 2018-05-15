-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show internal compilation environment parameters which are not related to KSP parameters

col fid_qkscesyrow head FUNCTION_ID for a20

SELECT 
    pname_qkscesyrow
--  , pnum_qkscesyrow
--  , kspnum_qkscesyrow
--  , fid_qkscesyrow        
  , pvalue_qkscesyrow     system_value
  , defpvalue_qkscesyrow  default_value
FROM x$qkscesys 
WHERE pname_qkscesyrow IN (
    SELECT pname_qkscesyrow 
    FROM x$qkscesys 
    MINUS 
    SELECT ksppinm 
    FROM x$ksppi
) 
ORDER BY pname_qkscesyrow
/
