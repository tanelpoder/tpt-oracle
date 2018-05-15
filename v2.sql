-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col view_name for a30
col text for a100 word_wrap
col v_owner for a25

prompt Show SQL text of views matching "&1"...

select owner v_owner, view_name, text from dba_views
where 
  upper(view_name) LIKE
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

select view_name, view_definition text from v$fixed_View_definition where upper(view_name) like upper('&1');

