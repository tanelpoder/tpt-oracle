-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TABLE test_impx;
CREATE TABLE test_impx  (
    id                  NUMBER         NOT NULL
  , owner               VARCHAR2(30)
  , object_name         VARCHAR2(128)
  , subobject_name      VARCHAR2(30)   
  , object_id           NUMBER         
  , data_object_id      NUMBER         
  , object_type         VARCHAR2(19)   
  , created             DATE           
  , last_ddl_time       DATE           
  , timestamp           VARCHAR2(19)   
  , status              VARCHAR2(7)    
  , temporary           VARCHAR2(1)    
  , generated           VARCHAR2(1)    
  , secondary           VARCHAR2(1)    
  , namespace           NUMBER         
  , edition_name        VARCHAR2(30)   
)
PARTITION BY RANGE (id) (
    PARTITION id_05m VALUES LESS THAN (6000000)  
  , PARTITION id_09m VALUES LESS THAN (MAXVALUE) 
)
/

INSERT
    /*+ APPEND */ INTO test_impx
SELECT 
    ROWNUM id, t.* 
FROM 
    dba_objects t
  , (SELECT 1 FROM dual CONNECT BY LEVEL <= 100) u -- cartesian join for generating lots of rows
/

@gts test_impx
