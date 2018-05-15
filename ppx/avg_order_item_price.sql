-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT /*+ MONITOR PARALLEL(4) */
    c.customer_id
  , c.cust_first_name
  , c.cust_last_name
  , c.credit_limit
  , o.order_mode
  , avg(oi.unit_price)
FROM
    soe.customers   c
  , soe.orders      o
  , soe.order_items oi
WHERE
-- join
    c.customer_id = o.customer_id
AND o.order_id    = oi.order_id
-- filter
AND o.order_mode = 'direct'
GROUP BY
    c.customer_id
  , c.cust_first_name
  , c.cust_last_name
  , c.credit_limit
  , o.order_mode
HAVING
    sum(oi.unit_price) > c.credit_limit * 1000
/

