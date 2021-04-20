COL snapsys_start FOR A23

WITH FUNCTION sleep(dur IN NUMBER) RETURN NUMBER IS
    BEGIN
        DBMS_LOCK.SLEEP(dur);
        RETURN 1;
    END;
SELECT /*+ LEADING (t1, slp) */
    TO_CHAR(sysdate, 'YYYY-MM-DD HH24:MI:SS') snapsys_start
  , t1.name
  , t2.value - t1.value delta
FROM
    (SELECT /*+ NO_MERGE */ name, value FROM v$sysstat) t1
  , (SELECT /*+ NO_MERGE */ sleep(&1) ret  FROM dual) slp
  , (SELECT /*+ NO_MERGE */ name, value FROM v$sysstat) t2
WHERE
    t1.name = t2.name
AND slp.ret = 1
AND t2.value - t1.value != 0
AND REGEXP_LIKE(t1.name, '&2', 'i')
/

