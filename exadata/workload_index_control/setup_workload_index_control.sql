-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


DEF schemaname=SOE1000G

GRANT SELECT ON sys.v_$session TO &schemaname;

-- DROP TABLE &schemaname..workload_control;
-- DROP TRIGGER &schemaname..workload_control_trigger;

CREATE TABLE &schemaname..workload_control (
    username           VARCHAR2(100) DEFAULT ('*')     NOT NULL
  , service_name       VARCHAR2(100) DEFAULT  '*'      NOT NULL 
  , module             VARCHAR2(100) DEFAULT  '*'      NOT NULL 
  , action                   VARCHAR2(100) DEFAULT  '*'      NOT NULL 
  , program                  VARCHAR2(100) DEFAULT  '*'      NOT NULL 
  , client_machine           VARCHAR2(100) DEFAULT  '*'      NOT NULL 
  , client_osuser            VARCHAR2(100) DEFAULT  '*'      NOT NULL 
  , indexes_visible          VARCHAR2(100) DEFAULT 'TRUE'     
  , force_serial_direct_read VARCHAR2(100) DEFAULT 'FALSE' 
  , CONSTRAINT pk_workload_control PRIMARY KEY (username, service_name, module, action, program, client_machine, client_osuser)
  , CONSTRAINT ck1_workload_control CHECK (indexes_visible IN ('TRUE','FALSE'))
  , CONSTRAINT ck2_workload_control CHECK (force_serial_direct_read IN ('TRUE', 'FALSE'))
);

INSERT INTO &schemaname..workload_control (username, indexes_visible) VALUES ('&schemaname', 'TRUE'); 
INSERT INTO &schemaname..workload_control (username, program, indexes_visible, force_serial_direct_read)
       VALUES ('&schemaname', 'sqlplus@mac02.local (TNS V1-V3)', 'FALSE', 'TRUE'); 
COMMIT;

CREATE OR REPLACE TRIGGER &schemaname..workload_control_trigger
    AFTER LOGON ON &schemaname..SCHEMA
DECLARE
    c NUMBER;
BEGIN
    -- set optimizer_use_invisible_indexes
    FOR s IN (SELECT * FROM v$session WHERE sid = SYS_CONTEXT('userenv', 'sid')) 
    LOOP -- this loop returns only 1 row
        SELECT COUNT(*) INTO c
        FROM &schemaname..workload_control ctl
        WHERE
            (ctl.username = s.username             OR ctl.username       = '*')
        AND (ctl.service_name = s.service_name     OR ctl.service_name   = '*')
        AND (ctl.module = s.module                 OR ctl.module         = '*')
        AND (ctl.action = s.action                 OR ctl.action         = '*')
        AND (ctl.program = s.program               OR ctl.program        = '*')
        AND (ctl.client_machine = s.machine        OR ctl.client_machine = '*')
        AND (ctl.client_osuser = s.osuser          OR ctl.client_osuser  = '*')
        AND indexes_visible = 'FALSE';

        IF c > 0 THEN
            EXECUTE IMMEDIATE 'alter session set optimizer_use_invisible_indexes = false';
        ELSE
            EXECUTE IMMEDIATE 'alter session set optimizer_use_invisible_indexes = true';
        END IF; 
    END LOOP;

    -- set _serial_direct_read
    FOR s IN (SELECT * FROM v$session WHERE sid = SYS_CONTEXT('userenv', 'sid')) 
    LOOP -- this loop returns only 1 row
        SELECT COUNT(*) INTO c
        FROM &schemaname..workload_control ctl
        WHERE
            (ctl.username = s.username             OR ctl.username       = '*')
        AND (ctl.service_name = s.service_name     OR ctl.service_name   = '*')
        AND (ctl.module = s.module                 OR ctl.module         = '*')
        AND (ctl.action = s.action                 OR ctl.action         = '*')
        AND (ctl.program = s.program               OR ctl.program        = '*')
        AND (ctl.client_machine = s.machine        OR ctl.client_machine = '*')
        AND (ctl.client_osuser = s.osuser          OR ctl.client_osuser  = '*')
        AND force_serial_direct_read = 'TRUE';

        IF c > 0 THEN
            EXECUTE IMMEDIATE 'alter session set "_serial_direct_read" = ALWAYS';
        END IF; 
    END LOOP;
END;
/

SHOW ERR

-- set all indexes invisible in your hybrid-workload schema
ALTER SESSION SET ddl_lock_timeout = 10;
BEGIN
    FOR i IN (SELECT index_name FROM user_indexes 
              WHERE table_name NOT IN 'WORKLOAD_CONTROL'
              AND table_owner NOT IN ('SYS', 'SYSTEM')
              AND table_owner = '&schemaname'
              AND visibility = 'VISIBLE')
    LOOP
        EXECUTE IMMEDIATE 'ALTER INDEX '||i.index_name||' INVISIBLE';
    END LOOP;
END;
/

