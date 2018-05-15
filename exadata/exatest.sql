-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TYPE mystats_t;
DROP TYPE mystats_r;
DROP PACKAGE exatest;
DROP TYPE mystats_t;

CREATE OR REPLACE VIEW mys AS
SELECT sn.name, my.value
FROM v$statname sn, v$mystat my
WHERE sn.statistic# = my.statistic#
/

CREATE OR REPLACE TYPE mystats_r AS OBJECT (name VARCHAR2(64), value NUMBER);
/

CREATE OR REPLACE TYPE mystats_t AS TABLE OF mystats_r
/

-- DROP PACKAGE exatest;
CREATE OR REPLACE PACKAGE exatest AS
    PROCEDURE snap;
    FUNCTION diff(filter IN VARCHAR2 DEFAULT NULL) RETURN mystats_t PIPELINED;
    stats mystats_t; 
END;
/

CREATE OR REPLACE PACKAGE BODY exatest AS

    prev_stats mystats_t;

    PROCEDURE SNAP AS
    BEGIN
        prev_stats := exatest.stats;
        SELECT mystats_r(name,value) BULK COLLECT INTO exatest.stats FROM mys;
    END snap;

    FUNCTION diff(filter IN VARCHAR2 DEFAULT NULL) RETURN mystats_t PIPELINED AS
    BEGIN
        snap;
        FOR i IN (SELECT        
                      now.name
                    , now.value - prev.value diff
                  FROM 
                      TABLE(CAST(exatest.stats AS mystats_t)) now
                    , TABLE(CAST(prev_stats AS mystats_t)) prev
                  WHERE prev.name = now.name
        ) LOOP
            IF FILTER IS NULL THEN
                IF i.diff != 0 THEN 
                    PIPE ROW (mystats_r(i.name,i.diff));
                END IF;
            ELSE
                IF REGEXP_LIKE(i.name, filter, 'i') THEN
                    PIPE ROW (mystats_r(i.name,i.diff));
                END IF;
            END IF; -- if filter is null
        END LOOP;
    END diff;

BEGIN
    snap;
END;
/
SHOW ERR


