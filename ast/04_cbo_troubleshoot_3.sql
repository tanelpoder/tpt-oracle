-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT /*+ 
           opt_param('_optimizer_use_feedback', 'false')
           cardinality(c o 50000)
           OPT_ESTIMATE(@"SEL$1", JOIN, ("C"@"SEL$1", "E"@"SEL$1" "D"@"SEL$1" "O"@SEL$1), SCALE_ROWS=100000)
           cardinality(c e d o 100000)
    */
    dep.department_name
  , e.first_name
  , e.last_name
  , prod.product_name
  , c.cust_first_name
  , c.cust_last_name
  , SUM(oi.quantity)
  , sum(oi.unit_price * oi.quantity) total_price
FROM
    hr.departments dep  -- 1
  , hr.employees   e    -- 1
  , oe.orders      o    -- ?
  , oe.order_items oi   -- ?
  , oe.products    prod -- 1
  , oe.customers   c    -- 1
  , oe.promotions  prom -- ?
WHERE
   -- joins
    o.order_id          = oi.order_id
AND oi.product_id       = prod.product_id 
AND o.promotion_id      = prom.promo_id (+)
AND o.customer_id       = c.customer_id
AND o.sales_rep_id      = e.employee_id
AND dep.department_id   = e.department_id
   -- filters
AND dep.department_name   = 'Sales'             -- 1 row
AND e.first_name        = 'William'           -- 1 row
AND e.last_name         = 'Smith'
AND prod.product_name   = 'Mobile Web Phone'  -- 1 row (view)
AND c.cust_first_name   = 'Gena'              --
AND c.cust_last_name    = 'Harris'            -- 1 row
GROUP BY
    dep.department_name
  , e.first_name
  , e.last_name
  , prod.product_name
  , c.cust_first_name
  , c.cust_last_name
 ORDER BY
    total_price
/ 
