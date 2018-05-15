-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

VAR snapper REFCURSOR

DEF snr_query="&1"

@snapper stats,begin 1 1 &mysid
PROMPT RUNNING SELECT * FROM (&snr_query);;
SELECT * FROM (&snr_query);
@snapper stats,end 1 1 &mysid

