-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT 
    (to_date(&1) - to_date('01011970','ddmmyyyy')) * 24*60*60 SECONDS_EPOCH
FrOM DUAL
/

