-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL sequence_owner FOR A25
COL sequence_name FOR A30

select * from dba_sequences 
where
    upper(sequence_name) LIKE 
                upper(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND sequence_owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
/

