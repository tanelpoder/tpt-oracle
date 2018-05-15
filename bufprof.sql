-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   BufProf 1.04 ( Buffer Get Profiler )  
-- Purpose:     Display buffer gets done by a session and their reason
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @bufprof <SID> <#samples>
-- 	            @bufprof 142 1000
--	        
-- Other:       This is an experimental script, which may or may not work for you
--              It's dependent on the size of the cache buffers handles array 
--              (db_handles), so if you have lots of sessions configured
--              scanning this repeatedly may be slow. 
--
--------------------------------------------------------------------------------


--DEF bufprof_cols=KCBBFSO_TYP,KCBBFSO_OWN,DECODE(KCBBFCR,1,'CR','CUR'),KCBBFWHR,KCBBFWHY,w.KCBWHDES,KCBBPBH,KCBBPBF,m.ksmmmval,p.sid,p.username,p.program
--DEF bufprof_cols=KCBBFSO_OWN,DECODE(KCBBFCR,1,'CR','CUR'),w.KCBWHDES,KCBBPBF,m.ksmmmval,p.sid
--DEF bufprof_cols=p.sid,kcbbfwhy,kcbbfso_flg,TO_CHAR(kcbbfflg,'XXXXXXXX'),TO_CHAR(KCBBFCM,'XXXXXXXX'),KCBBFSO_OWN,DECODE(KCBBFCR,1,'CR','CUR'),w.KCBWHDES
DEF bufprof_cols=p.sid,DECODE(KCBBFCR,1,'CR','CUR'),w.KCBWHDES

COL kcbwhdes FOR A35

COL bufprof_addrlen NEW_VALUE addrlen
COL bufprof_addrmask NEW_VALUE addrmask

SET TERMOUT OFF
SELECT VSIZE(addr) bufprof_addrlen, RPAD('0',VSIZE(addr)*2,'X') bufprof_addrmask FROM x$kcbsw WHERE ROWNUM = 1;
SET TERMOUT ON

DEF num_samples=&2

PROMPT
PROMPT -- BufProf 1.04 (experimental) by Tanel Poder ( http://www.tanelpoder.com )
PROMPT

-- hack, newer connect by code crashes
--alter session set optimizer_features_enable = '9.2.0.8';

--explain plan for
WITH 
    s  AS (SELECT /*+ NO_MERGE MATERIALIZE */ 1 r FROM DUAL CONNECT BY LEVEL <= &num_samples),
    p  AS (SELECT p.addr paddr, s.saddr saddr, s.sid sid, p.spid spid, s.username, s.program, s.terminal, s.machine 
           FROM v$process p, v$session s WHERE s.paddr = p.addr),
    t1 AS (SELECT hsecs FROM v$timer),
    samples AS (
        SELECT /*+ ORDERED NO_MERGE USE_NL(bf) USE_NL(m) USE_NL(p) USE_NL(w) */
        &bufprof_cols,
        m.ksmmmval                  proc_so,
--        bf.KCBBPBF,
        COUNT(*)                    total_samples
        FROM 
            s, -- this trick is here to avoid an ORA-600 in kkqcbydrv:1
            (SELECT /*+ NO_MERGE */ 
                    b.*, 
                    HEXTORAW( TRIM(TO_CHAR(TO_NUMBER(RAWTOHEX(b.kcbbfso_own),'&addrmask')+&addrlen*2,'&addrmask')) ) call_so -- call state object 
                    FROM x$kcbbf b 
                    WHERE 1=1
                    AND bitand(b.KCBBFSO_FLG,1) = 1
                    --AND b.KCBBFCM > 0
            ) bf,
            X$KSMMEM m,
            p,
            x$kcbwh w
        WHERE
          1=1
        AND bf.call_so = m.addr
        AND rawtohex(bf.call_so) > '00000002'
        AND m.ksmmmval = p.paddr -- compare the fetched word to process state object address
        AND BITAND(bf.KCBBFSO_FLG,1) = 1  -- buffer handle in use
        AND bf.kcbbfwhr = w.indx
        --AND (p.sid LIKE '&1' OR p.sid IS NULL)
        AND (p.sid LIKE '&1')
        AND (p.sid != (select sid from v$mystat where rownum = 1))
        GROUP BY &bufprof_cols , m.ksmmmval --,bf.KCBBPBF
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
