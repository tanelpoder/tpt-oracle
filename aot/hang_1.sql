DELETE FROM t1 WHERE rownum = 1;

EXEC dbms_lock.sleep(9999999)
