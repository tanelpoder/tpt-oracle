-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column lt_type 		heading "TYPE"		format a4
column lt_name		heading "LOCK NAME"	format a32
column lt_id1_tag	heading "ID1 MEANING"	format a25	word_wrap
column lt_id2_tag	heading "ID2 MEANING"	format a25	word_wrap
column lt_us_user	heading "USR"		format a3
column lt_description	heading "DESCRIPTION"	format a60	word_wrap

prompt Show lock type info from V$LOCK_TYPE for lock &1

select
	lt.type 	lt_type,
	lt.name 	lt_name,
	lt.id1_tag	lt_id1_tag,
	lt.id2_tag	lt_id2_tag,
	lt.is_user	lt_is_user,
	lt.description	lt_description
from 
	  v$lock_type lt
where 
	upper(type) like upper('&1')
/

