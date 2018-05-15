-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL addrlen NEW_VALUE addrlen
COL addrmask NEW_VALUE addrmask

SET TERMOUT OFF
SELECT VSIZE(addr) addrlen, LPAD('X',VSIZE(addr)*2,'X') addrmask FROM x$kcbsw WHERE ROWNUM = 1;
SET TERMOUT ON

--    ( SELECT /*+ INDEX(x$ksmmem) */ addr m1addr, HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(addr),'&addrmask')+&addrlen*2,'&addrmask')) ) m1parent_addr FROM x$ksmmem) m1,






--SELECT /*+ INDEX(x$ksmmem m) */
--    addr,
----    ksmmmval VALUE,
--    HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(addr),'&addrmask')+&addrlen*2,'&addrmask')) ) owner_addr
--FROM
--    x$ksmmem m
--WHERE addr > HEXTORAW('00')
--CONNECT BY 
--      HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(addr),'&addrmask')+&addrlen*2,'&addrmask')) ) = addr
--START WITH 
--      addr = hextoraw('&1')
--/

    
--SELECT /*+ ORDERED 
--           USE_NL(m2,m1) 
--           USE_NL(m3,m2) 
--           USE_NL(m4) 
--           USE_NL(m5) 
--           USE_NL(m6) 
--           USE_NL(m7) 
--           USE_NL(m8) 
--           USE_NL(m9) 
--           USE_NL(m10)
--           INDEX(m1)
--           INDEX(m2)
--           INDEX(m3)
--           INDEX(m4)
--           INDEX(m5)
--           INDEX(m6)
--           INDEX(m7)
--           INDEX(m8)
--           INDEX(m9)
--           INDEX(m10)
--           NO_MERGE(m1)
--           NO_MERGE(m2)
--    */
--    m1.m1addr,
--    m2.m2addr,
----    ksmmmval VALUE,
--    HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(m1addr),'&addrmask')+&addrlen*2,'&addrmask')) ) owner_addr
--FROM
--    ( SELECT /*+ NO_MERGE */ addr m1addr, HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(addr),'&addrmask')+&addrlen*2,'&addrmask')) ) m1parent_addr FROM x$ksmmem) m1,
--    ( SELECT /*+ NO_MERGE */ addr m2addr, HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(addr),'&addrmask')+&addrlen*2,'&addrmask')) ) m2parent_addr FROM x$ksmmem) m2
----    x$ksmmem m3,
----    x$ksmmem m4,
----    x$ksmmem m5,
----    x$ksmmem m6,
----    x$ksmmem m7,
----    x$ksmmem m8,
----    x$ksmmem m9,
----    x$ksmmem m10
--WHERE 
--    m1addr =  HEXTORAW('&1') 
--AND m2parent_addr =  m1addr
---- AND m3.addr =  HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(m2.addr),'&addrmask')+&addrlen*2,'&addrmask')) )
---- AND m4.addr =  HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(m3.addr),'&addrmask')+&addrlen*2,'&addrmask')) )
---- AND m5.addr =  HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(m4.addr),'&addrmask')+&addrlen*2,'&addrmask')) )
---- AND m6.addr =  HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(m5.addr),'&addrmask')+&addrlen*2,'&addrmask')) )
---- AND m7.addr =  HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(m6.addr),'&addrmask')+&addrlen*2,'&addrmask')) )
---- AND m8.addr =  HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(m7.addr),'&addrmask')+&addrlen*2,'&addrmask')) )
---- AND m9.addr =  HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(m8.addr),'&addrmask')+&addrlen*2,'&addrmask')) )
---- AND m10.addr = HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(m9.addr),'&addrmask')+&addrlen*2,'&addrmask')) )
--/

SELECT /*+ ORDERED */
    b.ksmmmval
FROM
    ( SELECT /*+ NO_MERGE */ ksmmmval FROM x$ksmmem WHERE addr = (SELECT /*+ NO_MERGE NO_UNNEST */ 
                                                                        CAST(HEXTORAW( 
                                                                                TRIM(TO_CHAR(TO_NUMBER('30F3C504','&addrmask')+&addrlen*2,'&addrmask')) 
                                                                               ) 
                                                                             AS RAW(4)
                                                                             ) 
                                                                        FROM DUAL
                                                                  ) 
    ) a,
    x$ksmmem b
WHERE
    a.ksmmmval = b.addr
/
