-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET HEADING OFF LINESIZE 10000 PAGESIZE 0 TRIMSPOOL ON TRIMOUT ON VERIFY OFF LONG 999999 LONGCHU

ACCEPT sqlid FORMAT A13 PROMPT "Enter sql_id: "

SET TERMOUT OFF
spool sqlmon_&sqlid..html

SELECT
  DBMS_SQLTUNE.REPORT_SQL_MONITOR(
     sql_id=>'&sqlid',
     report_level=>'ALL',
     type => 'ACTIVE') as report
FROM dual
/

SPOOL OFF
SET TERMOUT ON HEADING ON LINESIZE 999

PROMPT File spooled into sqlmon_&sqlid..html

