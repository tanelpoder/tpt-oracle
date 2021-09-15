WITH 
    bclass AS (SELECT /*+ INLINE */ class, ROWNUM r from v$waitstat)
  , sq AS (
    SELECT 
        REPLACE(SYS_CONNECT_BY_PATH(&1, '->'), '->', ' -> ')
               ||CASE WHEN CONNECT_BY_ISLEAF = 1 AND ses.blocking_session IS NOT NULL 
                      THEN ' -> [idle blocker '||ses.blocking_instance||','||ses.blocking_session||' ('||ses.program||')]' ELSE NULL   
                 END path
    FROM (
        SELECT
            s.*
          , CASE WHEN s.type = 'BACKGROUND' AND s.program LIKE '%(DBW%)' THEN
              '(DBWn)'
            WHEN s.type = 'BACKGROUND' OR REGEXP_LIKE(s.program, '.*\([PJ]\d+\)') THEN
              REGEXP_REPLACE(SUBSTR(s.program,INSTR(s.program,'(')), '\d', 'n')
            ELSE
                '('||REGEXP_REPLACE(REGEXP_REPLACE(s.program, '(.*)@(.*)(\(.*\))', '\1'), '\d', 'n')||')'
            END || ' ' program2
          , NVL(s.event||CASE WHEN event like 'enq%' AND state = 'WAITING'
                              THEN ' [mode='||BITAND(p1, POWER(2,14)-1)||']'
                              WHEN s.event IN (SELECT name FROM v$event_name WHERE parameter3 = 'class#')
                              THEN ' ['||NVL((SELECT class FROM bclass WHERE r = s.p3),'undo @bclass '||s.p3)||']' ELSE null END,'ON CPU') 
                       || ' ' event2
          , TO_CHAR(CASE WHEN state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
          , TO_CHAR(CASE WHEN state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
          , TO_CHAR(CASE WHEN state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
        FROM
            gv$session s
    ) ses
    CONNECT BY NOCYCLE
        (    PRIOR ses.blocking_session  = ses.sid
         AND PRIOR ses.blocking_instance = ses.inst_id
        )
    START WITH (ses.state='WAITING' AND ses.wait_class!='Idle') AND &2
)
SELECT
    COUNT(*) sessions
  , path
FROM
    sq
GROUP BY
    path
ORDER BY
    sessions DESC
/
