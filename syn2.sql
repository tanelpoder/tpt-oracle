-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col syn_db_link head DB_LINK for a30
col syn_owner head OWNER for a30
col syn_synonym_name head SYNONYM_NAME for a30
col syn_table_owner head TABLE_OWNER for a30
col syn_table_name head TABLE_NAME for a30

select
	owner syn_owner,
	synonym_name syn_synonym_name,
	table_owner syn_table_owner,
	table_name syn_table_name,
	db_link syn_db_link
from
  dba_synonyms 
where
  upper(synonym_name) LIKE 
        upper(CASE 
          WHEN INSTR('&1','.') > 0 THEN 
              SUBSTR('&1',INSTR('&1','.')+1)
          ELSE
              '&1'
          END
             ) ESCAPE '\'
AND owner LIKE
    CASE WHEN INSTR('&1','.') > 0 THEN
      UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
    ELSE
      user
    END ESCAPE '\'
/
