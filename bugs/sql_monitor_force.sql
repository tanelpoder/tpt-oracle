SELECT banner_full FROM v$version;

CREATE TABLE force_sqlmon TABLESPACE users AS SELECT * FROM dba_objects;

-- SELECT * FROM force_sqlmon; gives SQL_ID of 6v717k15utxsf

ALTER SYSTEM SET EVENTS 'sql_monitor [sql: 6v717k15utxsf] force=true';

SET TERMOUT OFF
SELECT * FROM force_sqlmon;
SET TERMOUT ON

SELECT * FROM v$sql_monitor WHERE sql_text LIKE '%force_sqlmon%';

