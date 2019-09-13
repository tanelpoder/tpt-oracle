-- demo1
-- the idea is to show that "slow sessions" do not always spend majority of time
-- actively working in the database, but spend time waiting for the application
-- to send the next command (application think time)

SET TIMING ON
SET ARRAYSIZE 15
SET APPINFO ON

PROMPT Running Report...
SET AUTOTRACE TRACE STAT

-- a "simple report" that returns lots of records
SELECT * FROM soe.customers WHERE credit_limit > 10;

--SELECT /*+ NO_PARALLEL */
--    c.customer_id
--  , c.cust_first_name ||' '||c.cust_last_name
--  , c.credit_limit
--FROM
--    soe.orders o
--  , soe.order_items oi
--  , soe.customers c
--WHERE
---- join conditions
--    c.customer_id = o.customer_id
--AND o.order_id    = oi.order_id
---- constant filter conditions
--AND c.customer_id BETWEEN 100000 AND 200000
----AND c.dob BETWEEN DATE'2000-01-01' AND DATE'2001-01-01'
--AND o.order_mode = 'online'
--AND o.order_status = 5
--/

SET AUTOTRACE OFF

