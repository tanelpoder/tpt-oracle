-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- enable physical IO tracing

@seg soe.orders
@ind soe.orders
@descxx soe.orders

ALTER SESSION SET EVENTS '10298 trace name context forever, level 1';
EXEC SYS.DBMS_MONITOR.SESSION_TRACE_ENABLE(waits=>TRUE);

SET TIMING ON
SET AUTOTRACE ON STAT

PAUSE Press enter to start...
SELECT /*+ MONITOR INDEX(o, o(warehouse_id)) */ SUM(order_total) FROM soe.orders o WHERE warehouse_id BETWEEN 400 AND 599;

SET AUTOTRACE OFF

