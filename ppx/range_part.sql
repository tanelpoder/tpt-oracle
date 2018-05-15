-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

CREATE TABLE &ppxuser..orders_range (
    order_id                                 NUMBER(12)   NOT NULL
  , order_date                               TIMESTAMP(6) NOT NULL
  , order_mode                               VARCHAR2(8)
  , customer_id                              NUMBER(12) NOT NULL
  , order_status                             NUMBER(2)
  , order_total                              NUMBER(8,2)
  , sales_rep_id                             NUMBER(6)
  , promotion_id                             NUMBER(6)
  , warehouse_id                             NUMBER(6)
  , delivery_type                            VARCHAR2(15)
  , cost_of_delivery                         NUMBER(6)
  , wait_till_all_available                  VARCHAR2(15)
  , delivery_address_id                      NUMBER(12)
  , customer_class                           VARCHAR2(30)
  , card_id                                  NUMBER(12)
  , invoice_address_id                       NUMBER(12)
)
PARTITION BY RANGE (order_date) (
    PARTITION Y2007_07 VALUES LESS THAN (DATE'2007-08-01')
  , PARTITION Y2007_08 VALUES LESS THAN (DATE'2007-09-01')
  , PARTITION Y2007_09 VALUES LESS THAN (DATE'2007-10-01')
  , PARTITION Y2007_10 VALUES LESS THAN (DATE'2007-11-01')
  , PARTITION Y2007_11 VALUES LESS THAN (DATE'2007-12-01')
  , PARTITION Y2007_12 VALUES LESS THAN (DATE'2008-01-01')
  , PARTITION Y2008_01 VALUES LESS THAN (DATE'2008-02-01')
  , PARTITION Y2008_02 VALUES LESS THAN (DATE'2008-03-01')
  , PARTITION Y2008_03 VALUES LESS THAN (DATE'2008-04-01')
  , PARTITION Y2008_04 VALUES LESS THAN (DATE'2008-05-01')
  , PARTITION Y2008_05 VALUES LESS THAN (DATE'2008-06-01')
  , PARTITION Y2008_06 VALUES LESS THAN (DATE'2008-07-01')
  , PARTITION Y2008_07 VALUES LESS THAN (DATE'2008-08-01')
  , PARTITION Y2008_08 VALUES LESS THAN (MAXVALUE)
)
COMPRESS
/

INSERT /*+ APPEND */ INTO &ppxuser..orders_range
SELECT * FROM &oeuser..orders
/

COMMIT;

EXEC DBMS_STATS.GATHER_TABLE_STATS('&ppxuser', 'ORDERS_RANGE');

