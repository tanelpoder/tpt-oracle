-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Taking a &1 second snapshot...

@@snapper "ash,stats,gather=t,tinclude=DB CPU" &1 1 all
