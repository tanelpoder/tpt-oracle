-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL originating_timestamp FOR a25
COL message_text FOR a100

SELECT to_char(originating_timestamp, 'yyyy-mm-dd hh24:mi:ss') AS originating_timestamp, message_text, container_name
FROM v$diag_alert_ext
WHERE component_id = 'rdbms'
AND originating_timestamp BETWEEN &1 AND &2
ORDER BY originating_timestamp;

CLEAR COLUMNS
