-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

drop table t;
create table t(a int);

create or replace package recursive_session_test 
--    authid definer  
as
    procedure p;
end;
/

create or replace package body recursive_session_test as 
    procedure p is                      
        pragma autonomous_transaction;  
    begin                               

	begin                               
--            insert into t values(1);
              insert into t select rownum from dual connect by level <=100000;
              dbms_lock.sleep(60);  
--            set transaction read only;
        exception                       
            when others then null;      
        end;                            
	p;                                  
    end;                                
                                        
begin                                   
    recursive_session_test.p;                                  
end;                                    
/                                       
show err

grant execute on recursive_session_test to public;

select q'\@sample "decode(bitand(ksuseflg,19),17,'BACKGROUND',1,'USER',2,'RECURSIVE','?'),ksuudsna" x$ksuse ksusepro=hextoraw('\'||hextoraw(paddr)||''') 10000' run_this
from v$session where sid = userenv('SID')
union all
select ' ' from dual
union all
select 'select decode(bitand(ksuseflg,19),17,''BACKGROUND'',1,''USER'',2,''RECURSIVE'',''?''),ksuudsna,ksusepro,ksspaown'||chr(10)
||'from x$ksuse'||chr(10)
||'where ksusepro=hextoraw('''||paddr||''');' run_this
from v$session where sid = userenv('SID');

--'

insert into t select rownum from dual connect by level <= 100000;

exec recursive_session_test.p;


--, STATUS
--, SERVER
--, SCHEMA#
--, SCHEMANAME
--, OSUSER
--, PROCESS
--, MACHINE
--, TERMINAL
--, PROGRAM
--, TYPE
--, SQL_ADDRESS
--, SQL_HASH_VALUE
--, SQL_ID
--, SQL_CHILD_NUMBER
--, PREV_SQL_ADDR
--, PREV_HASH_VALUE
--, PREV_SQL_ID
--, PREV_CHILD_NUMBER
--, MODULE
--, MODULE_HASH
--, ACTION
--, ACTION_HASH
--, CLIENT_INFO
--, FIXED_TABLE_SEQUENCE
--, ROW_WAIT_OBJ#
--, ROW_WAIT_FILE#
--, ROW_WAIT_BLOCK#
--, ROW_WAIT_ROW#
--, LOGON_TIME
--, LAST_CALL_ET
--, PDML_ENABLED
--, FAILOVER_TYPE
--, FAILOVER_METHOD
--, FAILED_OVER
--, RESOURCE_CONSUMER_GROUP
--, PDML_STATUS
--, PDDL_STATUS
--, PQ_STATUS
--, CURRENT_QUEUE_DURATION
--, CLIENT_IDENTIFIER
--, BLOCKING_SESSION_STATUS
--, BLOCKING_INSTANCE
--, BLOCKING_SESSION
--, SEQ#
--, EVENT#
--, EVENT
--, P1TEXT
--, P1
--, P1RAW
--, P2TEXT
--, P2
--, P2RAW
--, P3TEXT
--, P3
--, P3RAW
--, WAIT_CLASS_ID
--, WAIT_CLASS#
--, WAIT_CLASS
--, WAIT_TIME
--, SECONDS_IN_WAIT
--, STATE
--, SERVICE_NAME
--, SQL_TRACE
--, SQL_TRACE_WAITS
--, SQL_TRACE_BINDS )
--as
--select
--s.inst_id,s.addr,s.indx,s.ksuseser,s.ksuudses,s.ksusepro,s.ksuudlui,s.ksuudlna,s.ksuudoct,s.ksusesow
--,
--decode(s.ksusetrn,hextoraw('00'),null,s.ksusetrn),decode(s.ksqpswat,hextoraw('00'),null,s.ksqpswat),
--decode(bitand(s.ksuseidl,11),1,'ACTIVE',0,decode(bitand(s.ksuseflg,4096),0,'INACTIVE','CACHED'),2,'SNIPED',3,'SNIPED', 'KILLED'),
--decode(s.ksspatyp,1,'DEDICATED',2,'SHARED',3,'PSEUDO','NONE'),
--s.ksuudsid,s.ksuudsna,s.ksuseunm,s.ksusepid,s.ksusemnm,s.ksusetid,s.ksusepnm,
--decode(bitand(s.ksuseflg,19),17,'BACKGROUND',1,'USER',2,'RECURSIVE','?'), s.ksusesql, s.ksusesqh,
--s.ksusesqi, decode(s.ksusesch, 65535, to_number(null), s.ksusesch),  s.ksusepsq, s.ksusepha,
--s.ksusepsi,  decode(s.ksusepch, 65535, to_number(null), s.ksusepch),  s.ksuseapp, s.ksuseaph,
--s.ksuseact, s.ksuseach, s.ksusecli, s.ksusefix, s.ksuseobj, s.ksusefil, s.ksuseblk, s.ksuseslt,
--s.ksuseltm, s.ksusectm,decode(bitand(s.ksusepxopt, 12),0,'NO','YES'),decode(s.ksuseft, 2,'SESSION',
--4,'SELECT',8,'TRANSACTIONAL','NONE'),decode(s.ksusefm,1,'BASIC',2,'PRECONNECT',4,'PREPARSE','NONE'),
--decode(s.ksusefs, 1, 'YES','NO'),s.ksusegrp,decode(bitand(s.ksusepxopt,4),4,'ENABLED',decode(bitand(s.ksusepxopt,8),8,'FORCED',
--'DISABLED')),decode(bitand(s.ksusepxopt,2),2,'FORCED',decode(bitand(s.ksusepxopt,1),1,'DISABLED','ENABLED'))
--,decode(bitand(s.ksusepxopt,32),32,'FORCED',decode(bitand(s.ksusepxopt,16),16,'DISABLED','EN
--ABLED')),  s.ksusecqd, s.ksuseclid, decode(s.ksuseblocker,4294967295,'UNKNOWN',  4294967294,
--'UNKNOWN',4294967293,'UNKNOWN',4294967292,'NO HOLDER',  4294967291,'NOT IN WAIT','VALID'),
--decode(s.ksuseblocker, 4294967295,to_number(null),4294967294,to_number(null),
--4294967293,to_number(null), 4294967292,to_number(null),4294967291,
--to_number(null),bitand(s.ksuseblocker, 2147418112)/65536),decode(s.ksuseblocker,
--4294967295,to_number(null),4294967294,to_number(null), 4294967293,to_number(null),
--4294967292,to_number(null),4294967291,  to_number(null),bitand(s.ksuseblocker, 65535)),s.ksuseseq,
--s.ksuseopc,e.kslednam, e.ksledp1, s.ksusep1,s.ksusep1r,e.ksledp2,
--s.ksusep2,s.ksusep2r,e.ksledp3,s.ksusep3,s.ksusep3r,e.ksledclassid,  e.ksledclass#, e.ksledclass,
--decode(s.ksusetim,0,0,-1,-1,-2,-2, decode(round(s.ksusetim/10000),0,-1,round(s.ksusetim/10000))),
--s.ksusewtm,decode(s.ksusetim, 0, 'WAITING', -2, 'WAITED UNKNOWN TIME',  -1, 'WAITED SHORT TIME',
--decode(round(s.ksusetim/10000),0,'WAITED SHORT TIME','WAITED KNOWN TIME')),s.ksusesvc,
--decode(bitand(s.ksuseflg2,32),32,'ENABLED','DISABLED'),decode(bitand(s.ksuseflg2,64),64,'TRUE','FALSE'),
--decode(bitand(s.ksuseflg2,128),128,'TRUE','FALSE')
--from x$ksuse s, x$ksled e 
--where
--      s.ksuseopc=e.indx
----and bitand(s.ksspaflg,1)!=0 
----and bitand(s.ksuseflg,1)!=0 
