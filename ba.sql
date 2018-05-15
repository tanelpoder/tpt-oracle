-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col ba_blsiz head BLSZ for 99999

select 
--	addr,
	indx,hladdr,
	blsiz ba_blsiz,
	flag,lru_flag,ts#,file#,
	dbarfil,dbablk,class,state,mode_held,obj,tch 
from x$bh where ba = hextoraw(lpad('&1',16,0))
/

