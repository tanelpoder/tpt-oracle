-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Not listing tables without comments...

COLUMN comm_comments HEADING COMMENTS FORMAT a90 WORD_WRAP
COLUMN comm_owner    HEADING OWNER FORMAT A20 WRAP
COLUMN comm_table_name HEADING TABLE_NAME FORMAT A30 

SELECT 
    owner                   comm_owner 
  ,	table_name              comm_table_name 
  , comments comm_comments
FROM 
	all_tab_comments 
WHERE 
  comments is not null
AND
  upper(table_name) LIKE 
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

