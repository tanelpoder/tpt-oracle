------------------------------------------------------------------------------
--
-- Copyright 2017 Tanel Poder ( tanel@tanelpoder.com | http://tanelpoder.com )
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
------------------------------------------------------------------------------

ALTER SESSION SET plsql_optimize_level = 0;

DECLARE
    n NUMBER;
BEGIN
    FOR i IN 1 .. &1 LOOP
        n := DBMS_RANDOM.VALUE;
				EXECUTE IMMEDIATE q'[SELECT 
						prod.product_name
					, c.cust_first_name
					, c.cust_last_name
					, SUM(oi.quantity)
					, sum(oi.unit_price * oi.quantity) total_price
				FROM
						soe.orders      o
					, soe.order_items oi
					, soe.products    prod
					, soe.customers   c
				WHERE
					 -- joins
						o.order_id                 = oi.order_id
				AND oi.product_id              = prod.product_id 
				AND o.customer_id              = c.customer_id
					 -- filters
				AND prod.product_name          = 'Mobile Web Phone'||:v
				AND LOWER(c.cust_first_name)   = LOWER('Gena'||:v)
				AND LOWER(c.cust_last_name)    = LOWER('Harris'||:v)
				GROUP BY
						prod.product_name
					, c.cust_first_name
					, c.cust_last_name
				 ORDER BY
						total_price]'
				 USING n, n, n;
		END LOOP;
END LOOP;
/ 
