-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Taking a &1 second snapshot of wait "&2"...

@@snapper "stats,gather=w,winclude=&2" &1 1 all
