-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- uses 11g LISTAGG() function
-- on 10g, comement out LISTAGG or implement this idea properly:
--    http://www.williamrobertson.net/documents/one-row.html

SELECT LISTAGG(c) WITHIN GROUP (ORDER BY r) str FROM (
    SELECT 
        ROWNUM r
      , CHR(TO_NUMBER(SUBSTR(hex,((level-1)*2)+1,2), 'XX')) c
    FROM (
        SELECT 
             UPPER(REPLACE(TRANSLATE('&1',',',' '), ' ', '')) hex 
        FROM dual
    )
    CONNECT BY
        SUBSTR(hex,(level-1)*2,2) IS NOT NULL
    -- OR SUBSTR(hex,(level-1)*2,2) != '00'
    ORDER BY
        TRUNC((ROWNUM-1)/4)*4+4-MOD(ROWNUM-1,4)
)
/
