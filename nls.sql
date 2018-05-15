-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col nls_parameter head PARAMETER for a30
col nls_value head VALUE for a50

select
    parameter nls_parameter
  , value     nls_value
from v$nls_parameters -- nls_session_parameters 
order by 
    parameter
/

