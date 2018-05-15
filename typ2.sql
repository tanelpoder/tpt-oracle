-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select owner, type_name, typecode, attributes, methods 
from dba_types
where lower(type_name) like lower('&1')
/
