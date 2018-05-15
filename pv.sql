-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col pd_name head NAME for a50
col pd_value head VALUE for a30
column pd_descr heading DESCRIPTION format a55 word_wrap

prompt Show parameter which have value &1

select n.ksppinm pd_name, c.ksppstvl pd_value, n.ksppdesc pd_descr
from sys.x$ksppi n, sys.x$ksppcv c
where n.indx=c.indx
and (
	c.ksppstvl like '&1'
);
