-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Compare Optimizer Features Enable Parameter values
-- By Tanel Poder ( http://www.tanelpoder.com )
--   Requires opt_param_matrix table to be created (using tools/optimizer/optimizer_features_matrix.sql)
--   Requires Oracle 11g+ due to PIVOT clause (but you can rewrite this SQL in earlier versions)`

col pd_name head NAME for a50
col pd_value head VALUE for a30
column pd_descr heading DESCRIPTION format a70 word_wrap

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


prompt Compare Optimizer_Features_Enable Parameter differences
prompt for values &1 and &2

select m.*, n.ksppdesc pd_descr
from (
    select * 
    from opt_param_matrix 
    pivot( 
        max(substr(value,1,20)) 
        for opt_features_enabled in ('&1','&2')
    ) 
    where "'&1'" != "'&2'"
) m
, sys.x$ksppi n
, sys.x$ksppcv c
where
    n.indx=c.indx
and n.ksppinm = m.parameter
/

