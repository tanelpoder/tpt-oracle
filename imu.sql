-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   im.sql
-- Purpose:     Display In-Memory Undo (IMU) buffer usage
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @im.sql
--          
-- Other:       Does only show IMU buffers currently bound to a transaction
--              If you want to see all currently available IMU buffers,
--              remove the WHERE condition
--
--------------------------------------------------------------------------------

prompt Display private in-memory undo (IMU) buffers currently in use in the instance...

SELECT 
       KTIFPNO, 
       KTIFPSTA,
       KTIFPXCB         XCTADDR,
       KTIFPUPB         UBADDR,
       TO_NUMBER(KTIFPUPE, 'XXXXXXXXXXXXXXXX')-TO_NUMBER(KTIFPUPB, 'XXXXXXXXXXXXXXXX')      UBSIZE,
       (TO_NUMBER(KTIFPUPB, 'XXXXXXXXXXXXXXXX')-TO_NUMBER(KTIFPUPC, 'XXXXXXXXXXXXXXXX'))*-1 UBUSAGE,
       KTIFPRPB         RBADDR,
       TO_NUMBER(KTIFPRPE, 'XXXXXXXXXXXXXXXX')-TO_NUMBER(KTIFPRPB, 'XXXXXXXXXXXXXXXX')      RBSIZE,
       (TO_NUMBER(KTIFPRPB, 'XXXXXXXXXXXXXXXX')-TO_NUMBER(KTIFPRPC, 'XXXXXXXXXXXXXXXX'))*-1 RBUSAGE,
       KTIFPPSI,
       KTIFPRBS,
       KTIFPTCN
FROM X$KTIFP
WHERE KTIFPXCB != HEXTORAW('00')
/
