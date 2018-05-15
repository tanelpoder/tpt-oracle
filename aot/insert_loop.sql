COL c1 FOR A20

--DROP TABLE sys.tbind;
--CREATE TABLE sys.tbind (c1 VARCHAR2(4000), c2 NUMBER, c3 NUMBER, c4 NUMBER, c5 NUMBER);
--DROP TABLE system.tbind;
--CREATE TABLE system.tbind (c1 VARCHAR2(4000), c2 VARCHAR2(4000), c3 VARCHAR2(4000), c4 VARCHAR2(4000), c5 VARCHAR2(4000));

VAR b1 VARCHAR2(10)
VAR b2 NUMBER
VAR b3 NUMBER
VAR b4 NUMBER
VAR b5 NUMBER

EXEC :b1 := 'A'
EXEC :b2 := 1;
-- b3-b5 are NULL

INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);

VAR b1 VARCHAR2(33)
EXEC :b1 := 'A'

INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);

VAR b1 VARCHAR2(129)
EXEC :b1 := 'A'

INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);

VAR b1 VARCHAR2(2001)
EXEC :b1 := 'A'

INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);

VAR b1 VARCHAR2(4000)
EXEC :b1 := 'A'

INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);

VAR b1 CHAR
EXEC :b1 := 'A'

INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);

VAR b1 NCHAR
EXEC :b1 := 'A'

INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);

ALTER SESSION SET current_schema = SYSTEM;

INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);

ALTER SESSION SET nls_date_format = 'YYYY:MM:DD';

INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);
INSERT INTO tbind VALUES (:b1, :b2, :b3, :b4, :b5);

--@sqlid gbusbc081f8m4 %
--@nonshared gbusbc081f8m4 %

