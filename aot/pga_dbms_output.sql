SET SERVEROUTPUT ON SIZE UNLIMITED

BEGIN
  FOR x IN 1..&1*10 LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD('x',100,'x'));
  END LOOP;
END;
/


SET SERVEROUT OFF

DBMS_OUTPUT.PUT_LINE ('...')


SET SERVEROUT ON 

-> DBMS_OUTPUT.ENABLE(1000000)
-> DBMS_OUTPUT.PUT_LINE ('...') -> "plsql vc2 collection" (UGA)
-> DBMS_OUTPUT.PUT_LINE ('...') -> "plsql vc2 collection" (UGA)
-> DBMS_OUTPUT.PUT_LINE ('...') -> "plsql vc2 collection" (UGA)
-> DBMS_OUTPUT.PUT_LINE ('...') -> "plsql vc2 collection" (UGA)
-> DBMS_OUTPUT.PUT_LINE ('...') -> "plsql vc2 collection" (UGA)
-> DBMS_OUTPUT.PUT_LINE ('...') -> "plsql vc2 collection" (UGA)
-> DBMS_OUTPUT.PUT_LINE ('...') -> "plsql vc2 collection" (UGA)
-> DBMS_OUTPUT.PUT_LINE ('...') -> "plsql vc2 collection" (UGA)
-> DBMS_OUTPUT.PUT_LINE ('...') -> "plsql vc2 collection" (UGA)
-> DBMS_OUTPUT.PUT_LINE ('...') -> "plsql vc2 collection" (UGA)

DBMS_OUTPUT.GET_LINES(.....)


