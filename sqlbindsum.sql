
COL BIND_NAME FOR A30

SELECT * FROM (
    SELECT
        s.sql_id
      , position
      , bind_name
      , COUNT(DISTINCT s.address)      parents
      , COUNT(DISTINCT RAWTOHEX(s.address||':'||s.child_number)) children
      , COUNT(DISTINCT datatype) datatypes
      , COUNT(DISTINCT max_length) maxlengths
      , COUNT(DISTINCT array_len)  maxarraylens
    FROM
        v$sql s
      , v$sql_bind_metadata sbm
    WHERE
        s.child_address = sbm.address
    AND s.sql_id LIKE '&1'
    GROUP BY
        s.sql_id
      , sbm.position
      , sbm.bind_name
    ORDER BY
        s.sql_id
      , sbm.position
)
WHERE 
    rownum <= 30
/


--    1      ADDRESS                                  RAW(8)
--    2      POSITION                                 NUMBER
--    3      DATATYPE                                 NUMBER
--    4      MAX_LENGTH                               NUMBER
--    5      ARRAY_LEN                                NUMBER
--    6      BIND_NAME                                VARCHAR2(30)
--    7      CON_ID                                   NUMBER

