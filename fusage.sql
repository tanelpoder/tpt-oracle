-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


PROMPT Did you flush feature usage information to the repository?
PROMPT >>> EXEC dbms_feature_usage_internal.exec_db_usage_sampling(SYSDATE)

SELECT ul.name, ul.detected_usages
FROM dba_feature_usage_statistics ul
WHERE ul.version = (SELECT MAX(u2.version) 
                    FROM dba_feature_usage_statistics u2
                    WHERE ul.name = u2.name
                    AND UPPER(ul.name) LIKE UPPER('&1')
                    AND UPPER(u2.name) LIKE UPPER('&1')
                   )
/

