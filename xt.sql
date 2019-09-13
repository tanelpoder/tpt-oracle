-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column xt_time heading relative_time_sec format 99999999999.999999
column xt_seq# heading seq# format 99999999999999
column xtrace_data heading data format a180 word_wrap
column xt_event heading event format 999999
column xt_op heading op format 999
column xt_sid heading sid format 999999
column xt_file_loc heading file.c for a20	


select 
	time/1000000	xt_time, 
	seq#    xt_seq#,
	event   xt_event, 
  file_loc xt_file_loc, 	-- 11g
  "FUNCTION",				-- 11g
--  operation,				-- 11g
--  section,				-- 11g
--  op xt_op, 
	sid xt_sid, 
  --	data xtrace_data,
	CASE event
		WHEN 10812 THEN
			'rfile='||RPAD(
				DBMS_UTILITY.DATA_BLOCK_ADDRESS_FILE(
					TO_NUMBER(
						SUBSTR(REPLACE(data,'0x',''),7,2)||SUBSTR(REPLACE(data,'0x',''),5,2)||SUBSTR(REPLACE(data,'0x',''),3,2)||SUBSTR(REPLACE(data,'0x',''),1,2)
					  , 'XXXXXXXX'
					)
				),4
			)||
			' block='||RPAD(
				DBMS_UTILITY.DATA_BLOCK_ADDRESS_BLOCK(
					TO_NUMBER(
						SUBSTR(REPLACE(data,'0x',''),7,2)||SUBSTR(REPLACE(data,'0x',''),5,2)||SUBSTR(REPLACE(data,'0x',''),3,2)||SUBSTR(REPLACE(data,'0x',''),1,2)
					  , 'XXXXXXXX'
					)
				),8
			)||
			' cr_scn='||TO_CHAR(
				TO_NUMBER(
					SUBSTR(REPLACE(data,'0x',''),41,2)||SUBSTR(REPLACE(data,'0x',''),39,2)||SUBSTR(REPLACE(data,'0x',''),37,2)||SUBSTR(REPLACE(data,'0x',''),35,2)
				  , 'XXXXXXXX'
				)
			)
		ELSE
			data
	END AS xtrace_data
from 
	x$trace 
where
	&1
--      sid in (&1)
and time > (select max(time)-10000000000 from x$trace)
--and data not like 'KSL WAIT%'
and seq# > &_xt_seq
order by 
	time asc
, seq# asc
/

set termout off

def _xt_seq=0

column xtseqsave new_value _xt_seq noprint

select max(seq#) xtseqsave from x$trace
where sid = (select sid from v$mystat where rownum = 1);

set termout on

