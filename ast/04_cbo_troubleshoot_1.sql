-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT /*+ opt_param('_optimizer_use_feedback', 'false') */
    d.department_name
  , e.first_name
  , e.last_name
  , prod.product_name
  , c.cust_first_name
  , c.cust_last_name
  , SUM(oi.quantity)
  , sum(oi.unit_price * oi.quantity) total_price
FROM
    oe.orders      o
  , oe.order_items oi
  , oe.products    prod
  , oe.customers   c
  , oe.promotions  prom
  , hr.employees   e
  , hr.departments d
WHERE
   -- joins
    o.order_id          = oi.order_id
AND oi.product_id       = prod.product_id 
AND o.promotion_id      = prom.promo_id (+)
AND o.customer_id       = c.customer_id
AND o.sales_rep_id      = e.employee_id
AND d.department_id     = e.department_id
   -- filters
AND d.department_name   = 'Sales'
AND e.first_name        = 'William'
AND e.last_name         = 'Smith'
AND prod.product_name   = 'Mobile Web Phone'
AND c.cust_first_name   = 'Gena'
AND c.cust_last_name    = 'Harris'
GROUP BY
    d.department_name
  , e.first_name
  , e.last_name
  , prod.product_name
  , c.cust_first_name
  , c.cust_last_name
 ORDER BY
    total_price
/ 
