-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT * FROM dual dontrun;

@hash

@oddc optim

ALTER SESSION SET EVENTS 'trace [SQL_Optimizer] [sql:g40pz6bqjwbzt] controlc_signal()';

ALTER SYSTEM FLUSH SHARED_POOL;

SELECT * FROM dual pleaserun;
SELECT * FROM dual dontrun;
SELECT * FROM dual dontrun;

ALTER SESSION SET EVENTS 'trace [SQL_Optimizer] [sql:g40pz6bqjwbzt] off';

ALTER SESSION SET EVENTS 'trace [Parallel_Execution] [sql:g40pz6bqjwbzt] controlc_signal()';

SELECT * FROM dual dontrun;

ALTER SESSION FORCE PARALLEL QUERY PARALLEL 4;

SELECT * FROM dual dontrun;

ALTER SESSION SET EVENTS 'trace [Parallel_Execution] [sql:g40pz6bqjwbzt] off';


ALTER SYSTEM FLUSH SHARED_POOL;

ALTER SESSION SET EVENTS 'trace [SQL_Optimizer] [sql:g40pz6bqjwbzt] crash';

SELECT * FROM dual dontrun;


