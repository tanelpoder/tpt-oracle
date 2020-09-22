#!/bin/bash

# Copyright 2020 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

# usage: ./cbchammer2 <num_loops>
# notes:
#  the updated version will do an exclusive CBC get every 1000 loop iterations for long-running tasks
#  so if you schedule only 1000 loop iterations per connect, these guys will do just shared gets
#  after 1000th iteration we consider the task long running and they will start doing a select for update
#  with exclusive CBC get every 1000 iterations
# 
# schema creation:
# 
#  CREATE TABLE cbchammer (a INT);
#  INSERT INTO cbchammer VALUES (1);
#  INSERT INTO cbchammer VALUES (2);
#  COMMIT;
#  EXEC DBMS_STATS.GATHER_TABLE_STATS(user, 'CBCHAMMER')


CONN=system/oracle@linux01/linprd


SQL_CMD="
CONNECT $CONN
ALTER SESSION SET plsql_optimize_level = 0;   
DECLARE
    x NUMBER;
BEGIN
    FOR i IN 1 .. $1 LOOP
        IF i / 1000 <= 1 THEN 
            SELECT a INTO x FROM cbchammer WHERE a = 1;
        ELSE
            IF MOD(i,1000) = 0 THEN
                SELECT a INTO x FROM cbchammer WHERE a = 2 FOR UPDATE;
                COMMIT WRITE NOWAIT;
            ELSE
                SELECT a INTO x FROM cbchammer WHERE a = 1;
            END IF;
        END IF;
    END LOOP;
END;
/ 
"

while true
do 
    #printf "$SQL_CMD" 
    printf "$SQL_CMD" | sqlplus -s /nolog
    #sleep 0.1
done 

