-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

define spuser=&1

prompt Truncating &spuser SAWR$ tables...

set echo on

truncate table &spuser..SAWR$SNAPSHOTS;
truncate table &spuser..SAWR$SESSIONS;
truncate table &spuser..SAWR$SESSION_EVENTS;
truncate table &spuser..SAWR$SESSION_STATS;

set echo off

undefine spuser

