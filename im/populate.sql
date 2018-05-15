-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

ALTER SESSION SET "_inmemory_populate_wait"=TRUE;
EXEC SYS.DBMS_INMEMORY.POPULATE('&1','&2');
ALTER SESSION SET "_inmemory_populate_wait"=FALSE;
@imseg &1..&2

