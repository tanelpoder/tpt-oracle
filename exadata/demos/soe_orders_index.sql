-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT /*+ MONITOR LEADING(c,o,oi) FULL(c) INDEX(o) */
    c.customer_id
  , c.cust_first_name ||' '||c.cust_last_name
  , c.credit_limit
  , MAX(oi.unit_price * oi.quantity) avg_order_total
FROM
    soe.orders o
  , soe.order_items oi
  , soe.customers c
WHERE
-- join conditions
    c.customer_id = o.customer_id
AND o.order_id    = oi.order_id
-- constant filter conditions
AND c.nls_territory LIKE 'a%'
AND o.order_mode = 'online'
AND o.order_status = 5
GROUP BY
    c.customer_id
  , c.cust_first_name ||' '||c.cust_last_name
  , c.credit_limit
HAVING
    MAX(oi.unit_price * oi.quantity) > c.credit_limit * 2
/

