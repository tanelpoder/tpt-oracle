-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column lt_type 		heading "TYPE"		format a4
column lt_name		heading "LOCK_NAME"	format a30
column lt_id1_tag	heading "ID1_MEANING"	format a25	word_wrap
column lt_id2_tag	heading "ID2_MEANING"	format a25	word_wrap
column lt_us_user	heading "USR"		format a3
column lt_description	heading "DESCRIPTION"	format a60	word_wrap


select
        i       indx,
        to_char(i, 'XXXX') hex,
	type 	lt_type,
	name 	lt_name,
	id1_tag	lt_id1_tag,
	id2_tag	lt_id2_tag,
	is_user	lt_is_user,
	description	lt_description
from 
	(
            select
                rest.indx i, 
                rest.resname type, 
                rest.name name, 
                rest.id1 id1_tag, 
                rest.id2 id2_tag,
                decode(bitand(eqt.flags,1), 1, 'YES', 'NO') is_user, 
                rest.expl description
            from X$KSIRESTYP rest, X$KSQEQTYP eqt    
            where (rest.inst_id = eqt.inst_id) 
            and   (rest.indx = eqt.indx)
            and   (rest.indx > 0)
)
where 
	upper(type) like upper('&1')
/

