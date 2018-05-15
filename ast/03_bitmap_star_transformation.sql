-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- setting the 11.2 cardinality feedback option to false for demo stability purposes
exec execute immediate 'alter session set "_optimizer_use_feedback"=false'; exception when others then null;

SELECT  /*+ star_transformation */
    ch.channel_desc
  , co.country_iso_code co 
  , cu.cust_city
  , p.prod_category
  , sum(s.quantity_sold)
  , sum(s.amount_sold)
FROM
    sh.sales     s
  , sh.customers cu
  , sh.countries co
  , sh.products  p
  , sh.channels  ch
WHERE
    -- join
    s.cust_id     = cu.cust_id
AND cu.country_id = co.country_id
AND s.prod_id     = p.prod_id
AND s.channel_id  = ch.channel_id
    -- filter
AND ch.channel_class = 'Direct'  
AND co.country_iso_code = 'US'  
AND p.prod_category = 'Electronics'
GROUP BY
    ch.channel_desc
  , co.country_iso_code
  , cu.cust_city
  , p.prod_category
/

