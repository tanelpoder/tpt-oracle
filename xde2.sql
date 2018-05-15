-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   xde.sql ( X$ DEscribe )
-- Purpose:     Describe X$ tables, column offsets and report indexed fixed table
--              columns

--              
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @xde <table_name_pattern>

--              @xde x$ksl%
--
-- Other:       The IDX column shows whether given X$ table column is accessible
--              via internal index (if it's not null then the column is indexed)
--              
--------------------------------------------------------------------------------

column xde_kqfcoidx  heading IDX format 999
column xde_name      heading TABLE_NAME format a22
column xde_kqfconam  heading COLUMN_NAME format a30
column xde_data_type heading DATA_TYPE format a20
column xde_off_hex   heading OFF_HEX format a9

break on xde_name


prompt Describe X$ tables and show indexed columns...

select 
    t.kqftanam		xde_name, 
    c.kqfconam		xde_kqfconam, 
    decode(kqfcodty, 
		1, 'VARCHAR2',
		2, 'NUMBER',
		8, 'LONG',
		9, 'VARCHAR',
		12, 'DATE',
		23, 'RAW', 
		24, 'LONG RAW',
		58, 'CUSTOM OBJ',
		69, 'ROWID',
		96, 'CHAR',
		100, 'BINARY_FLOAT',
		101, 'BINARY_DOUBLE',
		105, 'MLSLABEL',
		106, 'MLSLABEL',
		111, 'REF',
		112, 'CLOB',
		113, 'BLOB', 
		114, 'BFILE', 
		115, 'CFILE',
		121, 'CUSTOM OBJ',
		122, 'CUSTOM OBJ',
		123, 'CUSTOM OBJ',
		178, 'TIME',
		179, 'TIME WITH TIME ZONE',
		180, 'TIMESTAMP',
		181, 'TIMESTAMP WITH TIME ZONE',
		231, 'TIMESTAMP WITH LOCAL TIME ZONE',
		182, 'INTERVAL YEAR TO MONTH',
		183, 'INTERVAL DAY TO SECOND',
		208, 'UROWID',
		'UNKNOWN')
		||'('
		||to_char(c.kqfcosiz)
		||')' xde_data_type,
--    c.kqfcodty,
    c.kqfcosiz, 
    c.kqfcooff                     offset, 
    lpad('0x'||trim(to_char(c.kqfcooff,'XXXXXX')),8) xde_off_hex, 
    to_number(decode(c.kqfcoidx,0,null,c.kqfcoidx)) xde_kqfcoidx
from 
--	v$fixed_table t, 
        x$kqfta t,
        x$kqfco c 
where 
        c.kqfcotab  = t.indx
--	t.object_id = c.kqfcotob 
and 
	upper(t.kqftanam) like upper('&1')
/
