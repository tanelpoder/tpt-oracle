-- Oracle join elimiation demo by Tanel Poder (https://tanelpoder.com)

DROP TABLE o;
DROP TABLE u;

CREATE TABLE u AS SELECT * FROM all_users;
CREATE TABLE o AS SELECT * FROM all_objects WHERE owner IN (SELECT username FROM all_users);

ALTER SESSION SET statistics_level = ALL;

-- set echo on

SELECT COUNT(*) FROM u, o WHERE u.username = o.owner;
SELECT * FROM TABLE(dbms_xplan.display_cursor(format=>'+OUTLINE -NOTE'));

SELECT COUNT(*) FROM u, o WHERE u.username = o.owner AND u.created IS NULL;
SELECT * FROM TABLE(dbms_xplan.display_cursor(format=>'+OUTLINE -NOTE'));

ALTER TABLE u ADD PRIMARY KEY (username);
ALTER TABLE o ADD CONSTRAINT fk_u FOREIGN KEY (owner) REFERENCES u(username);

SELECT COUNT(*) FROM u, o WHERE u.username = o.owner;
SELECT * FROM TABLE(dbms_xplan.display_cursor(format=>'+OUTLINE -NOTE'));

ALTER TABLE o DISABLE CONSTRAINT fk_u;

SELECT COUNT(*) FROM u, o WHERE u.username = o.owner;
SELECT * FROM TABLE(dbms_xplan.display_cursor(format=>'+OUTLINE -NOTE'));

ALTER TABLE o ENABLE NOVALIDATE CONSTRAINT fk_u;

SELECT COUNT(*) FROM u, o WHERE u.username = o.owner;
SELECT * FROM TABLE(dbms_xplan.display_cursor(format=>'+OUTLINE -NOTE'));

ALTER TABLE o ENABLE VALIDATE CONSTRAINT fk_u;

SELECT COUNT(*) FROM u, o WHERE u.username = o.owner;
SELECT * FROM TABLE(dbms_xplan.display_cursor(format=>'+OUTLINE -NOTE'));

-- set echo off
