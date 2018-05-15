-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   i2h.sql  (sql Id to Hash value)
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--              to show that SQL_ID is just a fancy representation of a hash value
--              of a library cache object name.
--
--              Converts SQL_ID to HASH_VALUE
--
-- Usage:       @i2h <sqlid>
--             
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
--
-- Copyright:   (c) 2007-2009 Tanel Poder
--
--------------------------------------------------------------------------------
select
    trunc(mod(sum((
        instr('0123456789abcdfghjkmnpqrstuvwxyz',substr(lower(trim('&1')),level,1))-1)*power(32,length(trim('&1'))-level)),power(2,32))) hash_value
    , lower(trim('&1')) sql_id
from
    dual
connect by
    level <= length(trim('&1'))
/
