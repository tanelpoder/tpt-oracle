-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col p_name head NAME for a40
col p_value head VALUE for a40
col p_descr head DESCRIPTION for a80

select n.ksppinm p_name, c.ksppstvl p_value
from sys.x$ksppi n, sys.x$ksppcv c
where n.indx=c.indx
and lower(n.ksppinm) like lower('%&1%');
