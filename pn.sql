-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col pd_name head NAME for a54
col pd_value head VALUE for a30
column pd_descr heading DESCRIPTION format a70 word_wrap

Prompt Show all parameters and session values from x$ksppi/x$ksppcv...

select 
   n.indx + 1 num
 , to_char(n.indx + 1, 'XXXX') n_hex
 , n.ksppinm pd_name
 , c.ksppstvl pd_value
 , n.ksppdesc pd_descr
from sys.x$ksppi n, sys.x$ksppcv c
where n.indx=c.indx
and (
--   lower(n.ksppinm) || ' ' || lower(n.ksppdesc) like lower('&1') 
--   or lower(n.ksppdesc) like lower('&1')
     n.indx + 1 in (&1)
);
