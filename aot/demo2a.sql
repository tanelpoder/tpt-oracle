-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   demo2a.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--              Will cause some recursive dynamic sampling activity
--              that does not show up in V$SESSION and ASH
--
--              Uses SwingBench Order Entry schema table (but you can use
--              any other large table for testing this effect).
--
--              Requires Oracle 11.2 or lower (12c works slightly differently)
--
-- Author:      Tanel Poder ( http://tanelpoder.com )
-- Copyright:   (c) Tanel Poder
--
--------------------------------------------------------------------------------

prompt Starting Demo2a...

set echo on

ALTER SYSTEM FLUSH SHARED_POOL;

SELECT /*+ DYNAMIC_SAMPLING(o 10) */ * FROM soe.order_items o WHERE order_id = 1;
SELECT /*+ DYNAMIC_SAMPLING(o 10) */ * FROM soe.order_items o WHERE order_id = 1;
SELECT /*+ DYNAMIC_SAMPLING(o 10) */ * FROM soe.order_items o WHERE order_id = 1;

ALTER SYSTEM FLUSH SHARED_POOL;

SELECT /*+ DYNAMIC_SAMPLING(o 10) */ * FROM soe.order_items o WHERE order_id = 1;
SELECT /*+ DYNAMIC_SAMPLING(o 10) */ * FROM soe.order_items o WHERE order_id = 1;
SELECT /*+ DYNAMIC_SAMPLING(o 10) */ * FROM soe.order_items o WHERE order_id = 1;

set echo off

