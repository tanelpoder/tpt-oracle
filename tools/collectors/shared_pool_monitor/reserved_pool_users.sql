-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- select * from v$shared_pool_reserved;
--CREATE TABLE tanel_ksmspr TABLESPACE USERS AS SELECT * FROM sys.x$ksmspr;
--CREATE TABLE tanel_kglob STORAGE (INITIAL 10M NEXT 10M PCTINCREASE 0)  TABLESPACE users AS SELECT * FROM sys.x$kglob;

SELECT 
    l.kglnaown owner
  , l.kglnaobj object_name
  , l.kglnahsh hash_value
  , decode(l.kglhdnsp,0,'CURSOR',1,'TABLE/PROCEDURE',2,'BODY',3,'TRIGGER', 4,'INDEX',5,'CLUSTER',6,'OBJECT',
                         13,'JAVA SOURCE',14,'JAVA RESOURCE', 15,'REPLICATED TABLE OBJECT',
                         16,'REPLICATION INTERNAL PACKAGE', 
                          17,'CONTEXT
                          POLICY',18,'PUB_SUB',19,'SUMMARY',20,'DIMENSION', 21,'APP CONTEXT',22,'STORED OUTLINE'
                          ,23,'RULESET',24,'RSRC PLAN',
                          25,'RSRC CONSUMER GROUP',26,'PENDING RSRC PLAN',27,'PENDING RSRC CONSUMER GROUP',
                          28,'SUBSCRIPTION',29,'LOCATION',30,'REMOTE OBJECT',
                          31,'SNAPSHOT METADATA',32,'JAVA SHARED DATA',33,'SECURITY PROFILE', 'INVALID NAMESPACE') obj_namespace
  , decode(bitand(l.kglobflg,3),0,'NOT LOADED',2,'NON-EXISTENT',3,'INVALID STATUS',
      decode(kglobtyp, 0,'CURSOR',1,'INDEX',2,'TABLE',3,'CLUSTER',4,'VIEW',
                          5,'SYNONYM',6,'SEQUENCE',7,'PROCEDURE',8,'FUNCTION',9,'PACKAGE',10, 'NON-EXISTENT',
                          11,'PACKAGE BODY',12,'TRIGGER',13,'TYPE',14,'TYPE BODY',
                          15,'OBJECT',16,'USER',17,'DBLINK',18,'PIPE',19,'TABLE PARTITION'
                          , 20,'INDEX PARTITION',21,'LOB',22,'LIBRARY',23,'DIRECTORY',24,'QUEUE',
                          25,'INDEX-ORGANIZED TABLE',26,'REPLICATION OBJECT GROUP',
                          27,'REPLICATION PROPAGATOR', 28,'JAVA SOURCE',29,'JAVA CLASS',30,'JAVA RESOURCE'
                          ,31,'JAVA JAR', 32,'INDEX TYPE',33,
                          'OPERATOR',34,'TABLE SUBPARTITION',35,'INDEX SUBPARTITION',
                          36, 'REPLICATED TABLE OBJECT',37,'REPLICATION INTERNAL PACKAGE', 38,'CONTEXT POLICY'
                          ,39,'PUB_SUB',40,'LOB PARTITION',41,'LOB SUBPARTITION', 42,'SUMMARY',43,'DIMENSION'
                          ,44,'APP CONTEXT',45,'STORED OUTLINE',46,'RULESET', 47,'RSRC PLAN',
                          48,'RSRC CONSUMER GROUP',49,'PENDING RSRC PLAN', 50,'PENDING RSRC CONSUMER GROUP'
                          ,51,'SUBSCRIPTION',52,'LOCATION', 53,'REMOTE OBJECT',54,'SNAPSHOT METADATA',55,'IFS'
                          , 56,'JAVA SHARED DATA',57,'SECURITY PROFILE','INVALID TYPE')) obj_type
  , s.ksmchptr
  , s.ksmchsiz
  , s.ksmchcls
  , s.ksmchcom
  , s.ksmchpar
FROM
      tanel_ksmspr s
    , tanel_kglob  l
  --  x$ksmspr s
  --, x$kglob  l
WHERE
    s.ksmchptr = l.kglobhd0
OR  s.ksmchptr = l.kglobhd1
OR  s.ksmchptr = l.kglobhd2
OR  s.ksmchptr = l.kglobhd3
OR  s.ksmchptr = l.kglobhd4
OR  s.ksmchptr = l.kglobhd5
OR  s.ksmchptr = l.kglobhd6
OR  s.ksmchptr = l.kglobhd7
ORDER BY
    s.ksmchsiz
/
