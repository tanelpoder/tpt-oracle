SELECT
    sid
  , username
  , prev_sql_id
  , event
  , program
  , machine
FROM 
    v$session
WHERE
    event = 'SQL*Net break/reset to client'
--AND UPPER(state) LIKE UPPER('&1')
/


