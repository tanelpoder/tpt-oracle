-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col aot_hash_owner head OWNER for a12
col aot_hash_name head NAME word_wrap for a30
col aot_hash_dblink head DBLINK for a12

SELECT
    kglnaown aot_hash_OWNER
  , kglnaobj aot_hash_NAME
  , kglnadlk aot_hash_DBLINK
  , kglnahsh HASH_VALUE
  , TO_CHAR(kglnahsh, 'xxxxxxxx') HASH_HEX
  , kglnahsv MD5_HASH
  , kglobt03 SQL_ID
  , kglobt30 PLAN_HASH
  , kglobt31 LIT_HASH
  , kglobt46 OLD_HASH
FROM
    x$kglob
WHERE
    lower(kglnaobj) like lower('&1')
/
