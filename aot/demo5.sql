-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   demo5.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--              Causes a session hang by creating a pipe instead of a tracefile
--              and enabling tracing then
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
-- Copyright:   (c) Tanel Poder
--
-- Notes:       Meant to be executed from an Unix/Linux Oracle DB server
--              Requires the TPT toolset login.sql to be executed (via putting
--              TPT directory into SQLPATH) so that &trc variable would be
--              initialized with tracefile name.
--
--------------------------------------------------------------------------------

prompt Starting demo5...

host mknod &trc p

alter session set sql_trace=true;

select * from dual;

