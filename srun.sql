-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DEF cmd="&1"

VAR snapper REFCURSOR
@snapper4 stats,begin 1 1 &mysid

clear buffer
1 &cmd
/

@snapper4 stats,end 1 1 &mysid

