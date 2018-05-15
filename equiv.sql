-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- DBA_REWRITE_EQUIVALENCES
-- Name                            Null?    Type
-- ------------------------------- -------- ----------------------------
-- OWNER                           NOT NULL VARCHAR2(128)
-- NAME                            NOT NULL VARCHAR2(128)
-- SOURCE_STMT                              CLOB
-- DESTINATION_STMT                         CLOB
-- REWRITE_MODE                             VARCHAR2(10)

COL equiv_owner      FOR A20 WRAP
COL equiv_name       FOR A30 WRAP
COL source_stmt      FOR A50 WORD_WRAP
COL destination_stmt FOR A50 WORD_WRAP

SELECT
   owner equiv_owner
 , name  equiv_name
 , rewrite_mode
-- , source_stmt
-- , destination_stmt
FROM
   dba_rewrite_equivalences
WHERE
  UPPER(name) LIKE 
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

