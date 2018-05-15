-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--DEF bufprof_cols=KCBBFSO_TYP,KCBBFSO_OWN,DECODE(KCBBFCR,1,'CR','CUR'),KCBBFWHR,KCBBFWHY,w.KCBWHDES,KCBBPBH,KCBBPBF,m.ksmmmval,p.sid,p.username,p.program
--DEF bufprof_cols=KCBBFSO_OWN,DECODE(KCBBFCR,1,'CR','CUR'),w.KCBWHDES,KCBBPBF,m.ksmmmval,p.sid
DEF bufprof_cols=kcbbfso_own,p.sid,DECODE(KCBBFCR,1,'CR','CUR'),w.KCBWHDES

COL kcbwhdes FOR A30

COL bufprof_addrlen NEW_VALUE addrlen
COL bufprof_addrmask NEW_VALUE addrmask

SET TERMOUT OFF
SELECT VSIZE(addr) bufprof_addrlen, LPAD('X',VSIZE(addr)*2,'X') bufprof_addrmask FROM x$kcbsw WHERE ROWNUM = 1;
SET TERMOUT ON

DEF num_samples=&2

WITH 
    s  AS (SELECT /*+ NO_MERGE MATERIALIZE */ 1 r FROM DUAL CONNECT BY LEVEL <= &num_samples),
    p  AS (SELECT p.addr paddr, s.saddr saddr, s.sid sid, p.spid spid, s.username, s.program, s.terminal, s.machine 
             FROM v$process p, v$session s WHERE s.paddr = p.addr),
    t1 AS (SELECT hsecs FROM v$timer),
    samples AS (
        SELECT /*+ ORDERED USE_NL(bf) USE_NL(m) USE_NL(b) */
        &bufprof_cols,
        COUNT(*)                    total_samples
        FROM 
            s, -- this trick is here to avoid an ORA-600 in kkqcbydrv:1
            (SELECT /*+ NO_MERGE */ caddr top_so, bf.*, m.* FROM 
                (SELECT /*+ NO_MERGE */ 
                        b.*, 
                        HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(b.kcbbfso_own),'&addrmask')+&addrlen*2,'&addrmask')) ) caddr -- call SO address
                        FROM x$kcbbf b 
                        WHERE bitand(b.KCBBFSO_FLG,1) = 1
                ) bf,
                x$ksmmem m
                WHERE
                    m.addr = bf.caddr
                AND BITAND(bf.KCBBFSO_FLG,1) = 1  -- buffer handle in use
            ) b,
            p,
            x$kcbwh w
        WHERE
            --m.addr = HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(bf.KCBBFSO_OWN),'&addrmask')+&addrlen,'&addrmask')) )
            --m.addr = bf.KCBBFSO_OWN
            b.top_SO = p.paddr(+)
        AND b.kcbbfwhr = w.indx
        AND (p.sid LIKE '&1' OR p.sid IS NULL)
        GROUP BY &bufprof_cols
    ),
    t2 AS (SELECT hsecs FROM v$timer)
SELECT /*+ ORDERED */
    s.*
    , (t2.hsecs - t1.hsecs) * 10 * s.total_samples / &num_samples active_pct
FROM
    t1,
    samples s,
    t2
ORDER BY
    s.total_samples DESC
/
