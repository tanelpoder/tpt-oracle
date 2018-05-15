-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

INSERT INTO oe.promotions
SELECT 10+rownum promo_id, 'promotion '||to_char(10+rownum)
FROM dual CONNECT BY level < 90
/

INSERT INTO oe.promotions VALUES (100, 'online super-sale');

exec dbms_stats.gather_schema_stats('OE');

exec dbms_stats.create_stat_table('OE', 'STATS_BACKUP');

exec dbms_stats.export_schema_stats('OE', 'STATS_BACKUP', 'AST_04_TROUBLE_01');

CREATE TABLE oe.tmp AS  SELECT * FROM oe.orders WHERE 1=0;

INSERT /*+ APPEND */ INTO oe.tmp
SELECT 
        oe.orders_seq.NEXTVAL
      , sysdate  -- order date
      , 'online' -- order mode
      , 189   -- customer id
      , 12    -- order status
      , 99.95 -- order_total
      , 171   -- sales rep
      , 100   -- promotion_id
      , null  -- warehouse_id -- added new column
    FROM
       dual CONNECT BY level <= 100000
/
COMMIT;

INSERT INTO oe.orders (
    order_id                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               NOT NULL NUMBER(12)
  , order_date                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             NOT NULL TIMESTAMP(6) WITH LOCAL TIME ZONE
  , order_mode                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      VARCHAR2(8)
  , customer_id                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            NOT NULL NUMBER(6)
  , order_status                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NUMBER(2)
  , order_total                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     NUMBER(8,2)
  , sales_rep_id                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NUMBER(6)
  , promotion_id
  , warehouse_id  -- added a new column              
)
SELECT * FROM oe.tmp
ORDER BY
    dbms_random.random -- to increase pk clustering factor
/

COMMIT;

BEGIN
    FOR i IN (SELECT order_id FROM oe.tmp) LOOP
        -- such a lousy loop is needed as there's a "single row" trigger on order_items tab 
        INSERT INTO oe.order_items (ORDER_ID,PRODUCT_ID,UNIT_PRICE,QUANTITY)
           VALUES ( i.order_id, 3337, 9.95, power(2,power(2,dbms_random.value(1,3))) );
        -- commit in a loop so i wouldnt blow up my little undo tablespace
        COMMIT; 
    END LOOP;
END;
/

-- save old "bad" stats
exec dbms_stats.export_schema_stats('OE', 'STATS_BACKUP', 'AST_04_TROUBLE_BEGIN');
-- to restore:
-- exec dbms_stats.import_schema_stats('OE', 'STATS_BACKUP', 'AST_04_TROUBLE_BEGIN', NO_INVALIDATE=>FALSE);

-- run the 04_cbo_troubleshoot_1.sql and troubleshoot! :)




