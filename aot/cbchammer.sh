#!/bin/bash

# Copyright 2020 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

# usage: ./cbchammer <num_loops>

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
    FOR I IN 1 .. $1 LOOP
     SELECT a INTO x FROM cbchammer WHERE ROWNUM = 1;
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

