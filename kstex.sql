-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col kstex_seqh head SEQH for 99999999999999

select 
	sid,
	pid,
	op    event, 
	id,
	val0, 
	func, 
	decode(id,1,'call',2,'return',3,'longjmp') calltype, 
	nvals,  
	val2, 
	val3,
	seqh + power(2,32) kstex_seqh, 
	seql 
from 
	x$kstex 
where
	sid like '&1'
order by
	seqh, seql asc
/

