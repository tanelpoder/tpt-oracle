-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- MOATS TOP script
-- MOATS packages and install code is located in tools/moats directory

-- Following settings should be mandatory and documented...
-- --------------------------------------------------------
set arrays 72
set lines 110
set pagesize 0
set head off
set tab off

-- Windows sqlplus properties for optimal output (relative to font):
--  * font: lucide console 12
--  * window size: height of 47

select * from table(moats.top(5));


