-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TABLE badly_correlated1;
DROP TABLE badly_correlated2;

CREATE TABLE badly_correlated1 (id, a, b, c, d, e, f, g, h, val) AS (
  SELECT rownum id, v.* FROM (
    SELECT
        mod(rownum, 100000) a
      , mod(rownum, 100000) b
      , mod(rownum, 100000) c
      , mod(rownum, 100000) d
      , mod(rownum, 100000) e
      , mod(rownum, 100000) f
      , mod(rownum, 100000) g
      , mod(rownum, 100000) h
      , lpad('x',100,'x')
    FROM 
        dual CONNECT BY LEVEL <= 100000
    UNION ALL
    SELECT
        90 a
      , 91 b
      , 92 c
      , 93 d
      , 94 e
      , 95 f
      , 96 g
      , 97 h
      , lpad('y',100,'y')
    FROM 
        dual CONNECT BY LEVEL <= 100000
  ) v
)
/

CREATE TABLE badly_correlated2 AS SELECT * FROM badly_correlated1;

ALTER TABLE badly_correlated1 MODIFY id PRIMARY KEY;
ALTER TABLE badly_correlated2 MODIFY id PRIMARY KEY;

CREATE INDEX idx1_badly_correlated1 ON badly_correlated1 (a,b,c,d,e,f,g);
CREATE INDEX idx1_badly_correlated2 ON badly_correlated2 (a,b,c,d,e,f,g);

EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'BADLY_CORRELATED1', method_opt=>'FOR TABLE', cascade=>true);
EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'BADLY_CORRELATED2', method_opt=>'FOR TABLE', cascade=>true);


select /*+ opt_param('_optimizer_use_feedback', 'false') */
    * 
from
    badly_correlated1 t1
  , badly_correlated2 t2
where
    t1.id = t2.id
and t1.a = 90 
and t1.b = 91 
and t1.c = 92 
and t1.d = 93 
and t1.e = 94 
and t1.f = 95
and t1.g = 96
and t1.h = 97
and t2.val like 'xy%'
/

@x

EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'BADLY_CORRELATED1', method_opt=>'FOR TABLE FOR ALL COLUMNS SIZE 254', cascade=>true);
EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'BADLY_CORRELATED2', method_opt=>'FOR TABLE FOR ALL COLUMNS SIZE 254', cascade=>true);

select /*+ opt_param('_optimizer_use_feedback', 'false') */
    * 
from
    badly_correlated1 t1
  , badly_correlated2 t2
where
    t1.id = t2.id
and t1.a = 90 
and t1.b = 91 
and t1.c = 92 
and t1.d = 93 
and t1.e = 94 
and t1.f = 95
and t1.g = 96
and t1.h = 97
and t2.val like 'xy%'
/

@x

-- create extended stats
select 
    dbms_stats.create_extended_stats(
        ownname => user
      , tabname=>'BADLY_CORRELATED1'
      , extension=>'(a,b,c,d,e,f,g,h)'
    ) 
from dual
/

select 
    dbms_stats.create_extended_stats(
        ownname => user
      , tabname=>'BADLY_CORRELATED2'
      , extension=>'(a,b,c,d,e,f,g,h)'
    ) 
from dual
/

EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'BADLY_CORRELATED1', method_opt=>'FOR TABLE FOR ALL COLUMNS SIZE 254', cascade=>true);
EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'BADLY_CORRELATED2', method_opt=>'FOR TABLE FOR ALL COLUMNS SIZE 254', cascade=>true);
 
select /*+ opt_param('_optimizer_use_feedback', 'false') */
    * 
from
    badly_correlated1 t1
  , badly_correlated2 t2
where
    t1.id = t2.id
and t1.a = 90 
and t1.b = 91 
and t1.c = 92 
and t1.d = 93 
and t1.e = 94 
and t1.f = 95
and t1.g = 96
and t1.h = 97
and t2.val like 'xy%'
/

@x
