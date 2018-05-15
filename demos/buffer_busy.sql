-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- DROP TABLE tbb;
-- DROP SEQUENCE tbb_seq;
-- 
-- CREATE SEQUENCE tbb_seq NOCACHE;
-- 
-- CREATE TABLE tbb (
--      id         NUMBER PRIMARY KEY
--    , val        NUMBER
--    , entry_date DATE
-- );
-- 
-- CREATE INDEX tbb_entry ON tbb(entry_date);
-- 
-- INSERT INTO tbb VALUES (0, 123, sysdate);
-- COMMIT;

DECLARE
   tmp_id NUMBER;
BEGIN

    WHILE TRUE LOOP

        SELECT MIN(id) INTO tmp_id FROM tbb;

        INSERT INTO tbb VALUES (tbb_seq.NEXTVAL, 123, sysdate);

        BEGIN
            DELETE FROM tbb WHERE id = tmp_id;
        EXCEPTION
            WHEN no_data_found THEN NULL;
        END;

        COMMIT;

    END LOOP;

END;
/





