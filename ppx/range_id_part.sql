-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

CREATE TABLE &PPXUSER..orders_id_range (
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
PARTITION BY RANGE (order_id) (
    PARTITION id_00m VALUES LESS THAN (1000000)
  , PARTITION id_01m VALUES LESS THAN (2000000)
  , PARTITION id_02m VALUES LESS THAN (3000000)
  , PARTITION id_03m VALUES LESS THAN (4000000)
  , PARTITION id_04m VALUES LESS THAN (5000000)
  , PARTITION id_05m VALUES LESS THAN (6000000)
  , PARTITION id_06m VALUES LESS THAN (7000000)
  , PARTITION id_07m VALUES LESS THAN (8000000)
  , PARTITION id_08m VALUES LESS THAN (9000000)
  , PARTITION id_09m VALUES LESS THAN (MAXVALUE)
)
TABLESPACE users
COMPRESS
/

INSERT /*+ APPEND */ INTO &PPXUSER..orders_id_range SELECT * FROM &OEUSER..orders
/

COMMIT;

