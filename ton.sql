-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set define ^

host ssh2 -q oracle@solaris01 "/usr/sbin/mknod ^trc p"
host start /wait /b ssh2 oracle@solaris01 "/usr/sfw/bin/gegrep -ie ""^3"" ^trc --line-buffered"

alter session set tracefile_identifier='';
alter session set events '^1 trace name context forever, level ^2';

set define &