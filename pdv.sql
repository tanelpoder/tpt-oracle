-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col pd_name head NAME for a40
col pd_value head VALUE for a30
column pd_descr heading DESCRIPTION format a55 word_wrap

select n.ksppinm pd_name, c.ksppstvl pd_value, n.ksppdesc pd_descr
from x$ksppi n, x$ksppcv c
where n.indx=c.indx
/* 
and (
   lower(n.ksppinm) like lower('%&1%') 
   or lower(n.ksppdesc) like lower('%&1%')
)
*/
and lower(to_char(c.ksppstvl)) like lower('&1');


