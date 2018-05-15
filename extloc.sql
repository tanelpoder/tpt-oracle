-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL owner FOR A30
COL table_name FOR A30
col driver for a20
col dirname for a30
col extloc_location head LOCATION for a50

SELECT 
    owner
  , table_name
  , directory_name dirname
  , location       extloc_location
FROM dba_external_locations
WHERE
  UPPER(table_name) LIKE 
        UPPER(CASE 
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

