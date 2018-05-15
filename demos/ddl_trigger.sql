-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   ddl_trigger.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--
--              Allows creating a DDL safeguard trigger, which prohibits
--              DDL on all objects except the ones listed.
--              This helps to work around accidential table/index dropping etc
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
--
-- Copyright:   (c) 2007-2009 Tanel Poder
--
--------------------------------------------------------------------------------

EXEC EXECUTE IMMEDIATE 'DROP TRIGGER ddl_trig'; EXCEPTION WHEN OTHERS THEN NULL;
DROP TABLE test_table;
DROP TABLE ddl_allowed_operations;

CREATE TABLE ddl_allowed_operations (
    owner               VARCHAR2(30)    NOT NULL
  , object_name         VARCHAR2(128)   NOT NULL
  , create_allowed      CHAR(1)         NOT NULL
  , alter_allowed       CHAR(1)         NOT NULL
  , drop_allowed        CHAR(1)         NOT NULL
  , truncate_allowed    CHAR(1)         NOT NULL
  , CONSTRAINT ddl_allowed_operations PRIMARY KEY ( owner, object_name )
)
ORGANIZATION INDEX
/

CREATE OR REPLACE TRIGGER ddl_trig
    BEFORE CREATE OR ALTER OR DROP OR TRUNCATE ON DATABASE

DECLARE

    l_create   CHAR(1);
    l_alter    CHAR(1);
    l_drop     CHAR(1);
    l_truncate CHAR(1);

BEGIN

    BEGIN
        SELECT create_allowed, alter_allowed, drop_allowed, truncate_allowed 
        INTO   l_create, l_alter, l_drop, l_truncate
        FROM   ddl_allowed_operations
        WHERE  owner = ora_dict_obj_owner
        AND    object_name = ora_dict_obj_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000, 'DDL on '||ora_dict_obj_owner||'.'||ora_dict_obj_name|| ' prohibited. Object not listed in DDL_ALLOWED_OPERATIONS table.');
    END;
    
    CASE ora_sysevent
        WHEN 'CREATE' THEN
            IF UPPER(l_create)   != 'Y' THEN 
                RAISE_APPLICATION_ERROR(-20000, 'CREATE on '||ora_dict_obj_owner||'.'||ora_dict_obj_name|| ' prohibited.');
            END IF;
        WHEN 'ALTER' THEN
            IF UPPER(l_alter)    != 'Y' THEN 
                RAISE_APPLICATION_ERROR(-20000, 'ALTER on '||ora_dict_obj_owner||'.'||ora_dict_obj_name|| ' prohibited.');
            END IF;
        WHEN 'DROP' THEN
            IF UPPER(l_drop)     != 'Y' THEN 
                RAISE_APPLICATION_ERROR(-20000, 'DROP on '||ora_dict_obj_owner||'.'||ora_dict_obj_name|| ' prohibited.');
            END IF;
        WHEN 'TRUNCATE' THEN
            IF UPPER(l_truncate) != 'Y' THEN 
                RAISE_APPLICATION_ERROR(-20000, 'TRUNCATE on '||ora_dict_obj_owner||'.'||ora_dict_obj_name|| ' prohibited.');
            END IF;
    END CASE;
    
END;
/

SHOW ERR

INSERT INTO ddl_allowed_operations VALUES (user, 'TEST_TABLE', 'Y', 'N', 'N', 'N');
COMMIT;

CREATE TABLE test_table (a INT);

-- DROP TABLE test_table;
-- TRUNCATE TABLE test_table;

-- UPDATE ddl_allowed_operations SET drop_allowed = 'Y' WHERE owner = user AND object_name = 'TEST_TABLE';
-- DROP TABLE test_table;
