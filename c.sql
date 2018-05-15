-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col c_objtype head OBJTYPE for a20
col c_kglhdnsp head NAMESPACE for a20
col c_kglnaobj head SQL_TEXT for a40 word_wrap &1
col c_kglnaown head OWNER for a25 word_wrap &1
col c_kglnadlk head DB_LINK for a25 word_wrap &1

select /*+ ORDERED USE_NL(o) */
	kglhdadr, 
	kglhdpar, 
	kglnatim tstamp, 
--	kglnaptm prev_tstamp, 
--	decode(kglhdnsp,0,'CURSOR',1,'TABLE/PROCEDURE',2,'BODY',3,'TRIGGER',
--		4,'INDEX',5,'CLUSTER',6,'OBJECT',13,'JAVA SOURCE',14,'JAVA RESOURCE', 15,'REPLICATED TABLE OBJECT',
--		16,'REPLICATION INTERNAL PACKAGE', 17,'CONTEXT POLICY',18,'PUB_SUB',19,'SUMMARY',20,'DIMENSION', 
--		21,'APP CONTEXT',22,'STORED OUTLINE',23,'RULESET',24,'RSRC PLAN', 25,'RSRC CONSUMER GROUP',
--		26,'PENDING RSRC PLAN',27,'PENDING RSRC CONSUMER GROUP', 28,'SUBSCRIPTION',29,'LOCATION',30,'REMOTE OBJECT',
--		31,'SNAPSHOT METADATA',32,'JAVA SHARED DATA',33,'SECURITY PROFILE', 'INVALID NAMESPACE') c_kglhdnsp,
	decode(bitand(kglobflg,3),0,'NOT LOADED',2,'NON-EXISTENT',3,'INVALID STATUS', 
		decode(kglobtyp,0,'CURSOR',1,'INDEX',2,'TABLE',3,'CLUSTER',4,'VIEW', 5,'SYNONYM',6,'SEQUENCE',7,'PROCEDURE',
		8,'FUNCTION',9,'PACKAGE',10, 'NON-EXISTENT',11,'PACKAGE BODY',12,'TRIGGER',13,'TYPE',14,'TYPE BODY', 
		15,'OBJECT',16,'USER',17,'DBLINK',18,'PIPE',19,'TABLE PARTITION', 20,'INDEX PARTITION',21,'LOB',22,'LIBRARY',
		23,'DIRECTORY',24,'QUEUE', 25,'INDEX-ORGANIZED TABLE',26,'REPLICATION OBJECT GROUP', 27,'REPLICATION PROPAGATOR', 
		28,'JAVA SOURCE',29,'JAVA CLASS',30,'JAVA RESOURCE',31,'JAVA JAR', 32,'INDEX TYPE',33, 'OPERATOR',
		34,'TABLE SUBPARTITION',35,'INDEX SUBPARTITION', 36, 'REPLICATED TABLE OBJECT',37,'REPLICATION INTERNAL PACKAGE', 
		38,'CONTEXT POLICY',39,'PUB_SUB',40,'LOB PARTITION',41,'LOB SUBPARTITION', 42,'SUMMARY',43,'DIMENSION',
		44,'APP CONTEXT',45,'STORED OUTLINE',46,'RULESET', 47,'RSRC PLAN',48,'RSRC CONSUMER GROUP',49,'PENDING RSRC PLAN', 
		50,'PENDING RSRC CONSUMER GROUP',51,'SUBSCRIPTION',52,'LOCATION', 53,'REMOTE OBJECT',54,'SNAPSHOT METADATA',
		55,'IFS', 56,'JAVA SHARED DATA',57,'SECURITY PROFILE','INVALID TYPE')) as cc_objtype,
	kglobhs0+kglobhs1+kglobhs2+kglobhs3+kglobhs4+kglobhs5+kglobhs6 heapsize,
	kglhdldc,
	kglhdexc,
	kglhdlkc,
	kglobpc0,
	decode(kglhdkmk,0,'NO','YES'),
	kglhdclt, 
	kglhdivc,
	kglhdkmk,
	kglnaown	c_kglnaown,
	kglnaobj 	c_kglnaobj,
	kglnadlk        c_kglnadlk
from 
  v$open_cursor c
, x$kglob o
where 
        c.hash_Value = o.kglnahsh
and     c.address = o.kglhdadr
--and 	o.kglnaobj = 'select /*tanel*/ * from dual'
--and 	c.sid = (select sid from v$mystat where rownum = 1)
and 	c.sid in (&2)
--kglhdadr in ( 
--		select /**/ address from v$open_cursor
--		where sid = (select sid from v$mystat where rownum = 1)
--	)
/
