-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TABLE t;

CREATE TABLE t AS SELECT * FROM dba_objects;
CREATE INDEX i1 ON t(owner);
CREATE INDEX i2 ON t(owner,object_name);
CREATE INDEX i3 ON t(owner,subobject_name);
CREATE INDEX i4 ON t(owner,object_id);
CREATE INDEX i5 ON t(owner,data_object_id);
CREATE INDEX i6 ON t(owner,object_type);
CREATE INDEX i7 ON t(owner,created);
CREATE INDEX i8 ON t(owner,last_ddl_time);
CREATE INDEX i9 ON t(owner,timestamp);
CREATE INDEX i10 ON t(owner,status);

EXEC DBMS_STATS.GATHER_TABLE_STATS(USER,'T',NULL,100,METHOD_OPT=>'FOR ALL COLUMNS SIZE 254');

SELECT * FROM t
WHERE owner IN (SELECT owner FROM t GROUP BY owner HAVING count(*) > 1)
AND   owner NOT IN (SELECT owner FROM t WHERE owner NOT LIKE 'S%')
;
 
