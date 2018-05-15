-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show triggers by table/trigger name &1....
col trig_triggering_event for a30
col trigger_body for a80 word_wrap

COL table_owner    FOR A20
COL table_name     FOR A30
COL trigger_owner  FOR A20
COL trigger_name   FOR A30

select table_owner, table_name, owner trigger_owner, trigger_name, trigger_type, triggering_event trig_triggering_event, trigger_body
from dba_triggers 
where (
    UPPER(table_name) LIKE
                UPPER(CASE
                    WHEN INSTR('&1','.') > 0 THEN
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND UPPER(table_owner) LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
)
OR (
    UPPER(trigger_name) LIKE
                UPPER(CASE
                    WHEN INSTR('&1','.') > 0 THEN
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND UPPER(owner) LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
)
order by
    table_owner,
    table_name,
    trigger_name
/

