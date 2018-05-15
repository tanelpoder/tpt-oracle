-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT 
    TO_CHAR(TO_DATE('01011970','DDMMYYYY') + 1/24/60/60 * &1, 'DD-MON-YYYY HH24:MI:SS') "DATE"
FROM DUAL
/

