-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Taken and customized from http://docs.oracle.com/cd/E18283_01/appdev.112/e17125/adfns_xa.htm

-- CREATE TABLE xa_t (a INT, b VARCHAR2(100));
-- INSERT INTO xa_t VALUES (1, 'tanel is testing');
-- COMMIT;

SET SERVEROUT ON

--ACCEPT global_trans_id NUMBER DEFAULT 123 PROMPT "Enter value for global_trans_id [123]: "
DEF global_trans_id = &1
PROMPT

REM Session 1 starts a transaction and does some work.
DECLARE
  gtid NUMBER := &global_trans_id;

  PROCEDURE handle_err (rc IN PLS_INTEGER, p_comment IN VARCHAR2 DEFAULT 'N/A') IS
      xae EXCEPTION;
      oer PLS_INTEGER;
  BEGIN
      IF rc!=DBMS_XA.XA_OK THEN
          oer := DBMS_XA.XA_GETLASTOER();
          DBMS_OUTPUT.PUT_LINE('ORA-' || oer || ' occurred, XA call '||p_comment||' failed');
          RAISE xae;
      ELSE 
          DBMS_OUTPUT.PUT_LINE('XA call '||p_comment||' succeeded');
      END IF;
  END handle_err;

BEGIN
  HANDLE_ERR(SYS.DBMS_XA.XA_SETTIMEOUT(5), 'XA_SETTIMEOUT');
  HANDLE_ERR(DBMS_XA.XA_START(DBMS_XA_XID(gtid), DBMS_XA.TMNOFLAGS), 'XA_START   ('||gtid||')');
  UPDATE xa_t SET b = 'tanel is not testing anymore' WHERE a = 1;
  HANDLE_ERR(DBMS_XA.XA_END(DBMS_XA_XID(gtid), DBMS_XA.TMSUSPEND), 'XA_END/SUSP('||gtid||')');

  HANDLE_ERR(DBMS_XA.XA_PREPARE(DBMS_XA_XID(gtid)),  'XA_PREPARE ('||gtid||')');
  -- this is not needed for our test
  -- DBMS_LOCK.SLEEP(10);
  -- HANDLE_ERR(DBMS_XA.XA_ROLLBACK(DBMS_XA_XID(gtid)), 'XA_ROLLBACK('||gtid||')');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('XA error occurred, rolling back the transaction ...');
        DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_STACK);
        DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_CALL_STACK);
        HANDLE_ERR(DBMS_XA.XA_END(DBMS_XA_XID(gtid), DBMS_XA.TMSUCCESS), 'XA_END/SUCC('||gtid||')');
        HANDLE_ERR(DBMS_XA.XA_ROLLBACK(DBMS_XA_XID(gtid)), 'XA_ROLLBACK('||gtid||')');

END;
/

PROMPT Now wait for 10 seconds and run SELECT * FROM dba_2pc_pending;;

EXEC DBMS_LOCK.SLEEP(10);

COL tran_comment FOR A20
COL global_tran_id FOR A20

SELECT * FROM dba_2pc_pending WHERE state != 'forced rollback';

SET SERVEROUT OFF

