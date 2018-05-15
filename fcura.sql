-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col fcura_addrlen new_value _fcura_addrlen

set termout off
select vsize(addr)*2 fcura_addrlen from x$dual;
set termout on

col fcura_sql_text heading SQL_TEXT format a156 word_wrap
--break on fcura_sql_text

--select sql_text fcura_sql_text
--from v$sql 
--where lower(child_address) like lower('%&1%')
--or lower(address) like lower('%&1%');

--select hash_value, sql_id, address, child_number, child_address, object_status status
--from v$sql 
--where lower(child_address) like lower('%&1%')
--or lower(address) like lower('%&1%');


col curheaps_size0 heading SIZE0 for 99999
col curheaps_size6 heading SIZE6 for 99999
col fcura_kglnaobj heading OBJECT_NAME for a80 word_wrap

col MATCHING_HEAP new_value v_matching_heap
col KGLOBHD0 new_value v_curheaps_kglobhd0
col KGLOBHD6 new_value v_curheaps_kglobhd6

select 
	KGLNAHSH,
	KGLHDPAR,
	KGLOBT09 CHILD#,
	KGLHDADR,
	KGLOBHD0, --KGLOBHS0 curheaps_size0,
/*	KGLOBHD1,
	KGLOBHD2,
	KGLOBHD3,
	KGLOBHD4,
	KGLOBHD5,*/
	KGLOBHD6, --KGLOBHS6 curheaps_size6,
--,
--	KGLOBHD7,
--	KGLOBT00 CTXSTAT,
	KGLOBSTA STATUS,
	DECODE( hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0')), 
		KGLOBHD0, 'KGLOBHD0: '||KGLOBHD0,
		KGLOBHD1, 'KGLOBHD1: '||KGLOBHD1,
		KGLOBHD2, 'KGLOBHD2: '||KGLOBHD2,
		KGLOBHD3, 'KGLOBHD3: '||KGLOBHD3,
		KGLOBHD4, 'KGLOBHD4: '||KGLOBHD4,
		KGLOBHD5, 'KGLOBHD5: '||KGLOBHD5,
		KGLOBHD6, 'KGLOBHD6: '||KGLOBHD6,
		KGLHDPAR, 'KGLHDPAR: '||KGLHDPAR,
		KGLHDADR, 'KGLHDADR: '||KGLHDADR,
		'00'
	) MATCHING_HEAP,
        CASE WHEN TRIM(KGLNAOWN) IS NULL THEN KGLNAOBJ ELSE KGLNAOWN||'.'||KGLNAOBJ END fcura_kglnaobj
from 
	X$KGLOB
--	X$KGLCURSOR_CHILD
where
    KGLHDPAR = hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0'))
or  KGLHDADR = hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0'))
or  KGLOBHD0 = hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0'))
or  KGLOBHD1 = hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0'))
or  KGLOBHD2 = hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0'))
or  KGLOBHD3 = hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0'))
or  KGLOBHD4 = hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0'))
or  KGLOBHD5 = hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0'))
or  KGLOBHD6 = hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0'))
/

--select 'HEAPx' heap, h.* from x$ksmhp h where KSMCHDS = hextoraw(hextoraw(lpad(upper('&1'), &_fcura_addrlen, '0')));
select 'HEAP0' heap, h.* from x$ksmhp h where KSMCHDS = hextoraw('&v_curheaps_kglobhd0');
select 'HEAP6' heap, h.* from x$ksmhp h where KSMCHDS = hextoraw('&v_curheaps_kglobhd6');

undef v_matching_heap
undef v_curheaps_kglobhd0
undef v_curheaps_kglobhd6
