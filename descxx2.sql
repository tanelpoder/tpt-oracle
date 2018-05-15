-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- descxx.sql requires the display_raw function which is included in the comment section below.
-- the display_raw function is taken from Greg Rahn's blog as I'm too lazy to write one myself
--     http://structureddata.org/2007/10/16/how-to-display-high_valuelow_value-columns-from-user_tab_col_statistics/
--
-- create or replace function display_raw (rawval raw, type varchar2)
--return varchar2
--is
--   cn     number;
--   cv     varchar2(128);
--   cd     date;
--   cnv    nvarchar2(128);
--   cr     rowid;
--   cc     char(128)
--begin
--   if (type = 'NUMBER') then
--      dbms_stats.convert_raw_value(rawval, cn);
--      return to_char(cn);
--   elsif (type = 'VARCHAR2') then
--      dbms_stats.convert_raw_value(rawval, cv);
--      return to_char(cv);
--   elsif (type = 'DATE') then
--      dbms_stats.convert_raw_value(rawval, cd);
--      return to_char(cd);
--   elsif (type = 'NVARCHAR2') then
--      dbms_stats.convert_raw_value(rawval, cnv);
--      return to_char(cnv);
--   elsif (type = 'ROWID') then
--      dbms_stats.convert_raw_value(rawval, cr);
--      return to_char(cnv);
--   elsif (type = 'CHAR') then
--      dbms_stats.convert_raw_value(rawval, cc);
--      return to_char(cc);
--   else
--      return 'UNKNOWN DATATYPE';
--   end if;
--end;
--/
--
-- grant execute on display_raw to public;
-- create public synonym display_raw for display_raw;



COL desc_column_id 		HEAD "Col#" FOR A4
COL desc_column_name	        HEAD "Column Name" FOR A30
COL desc_data_type		HEAD "Type" FOR A20 WORD_WRAP
COL desc_nullable		HEAD "Null?" FOR A10
COL desc_low_value HEAD "Low Value" FOR A32
COL desc_high_value HEAD "High Value" FOR A32

--prompt eXtended describe of &1

SELECT
  owner,
  table_name,
	CASE WHEN hidden_column = 'YES' THEN 'H' ELSE ' ' END||
	LPAD(column_id,3)	desc_column_id,
	column_name	desc_column_name,
	CASE WHEN nullable = 'N' THEN 'NOT NULL' ELSE NULL END AS desc_nullable,
	data_type||CASE 
--					WHEN data_type = 'NUMBER' THEN '('||data_precision||CASE WHEN data_scale = 0 THEN NULL ELSE ','||data_scale END||')' 
					WHEN data_type = 'NUMBER' THEN '('||data_precision||','||data_scale||')' 
					ELSE '('||data_length||')'
				END AS desc_data_type,
--	data_default,
	num_distinct,
	density,
	num_nulls,
	num_buckets,
        -- histogram,
	display_raw(low_value, data_type)   desc_low_value,
	display_raw(high_value, data_type)  desc_high_value
FROM
	dba_tab_cols
WHERE
	upper(table_name) LIKE 
				upper(CASE 
					WHEN INSTR('&1','.') > 0 THEN 
					    SUBSTR('&1',INSTR('&1','.')+1)
					ELSE
					    '&1'
					END
				     )
AND	owner LIKE
		CASE WHEN INSTR('&1','.') > 0 THEN
			UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
		ELSE
			user
		END
ORDER BY
  owner,
  table_name,
	column_id 
/

