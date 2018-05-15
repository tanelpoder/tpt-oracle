-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col ol_sql_text head SQL_TEXT for a80 word_wrap

select
    owner
  , name
  , category
  , used
  , enabled
  , sql_text     ol_sql_text
from
    dba_outlines
where
    lower(owner) like lower('&1')
and lower(name)  like lower('&2')
/

