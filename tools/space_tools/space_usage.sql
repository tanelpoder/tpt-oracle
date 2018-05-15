-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

CREATE OR REPLACE PACKAGE space_tools AS
    FUNCTION get_space_usage(owner IN VARCHAR2, object_name IN VARCHAR2, segment_type IN VARCHAR2, partition_name IN VARCHAR2 DEFAULT NULL) RETURN sys.DBMS_DEBUG_VC2COLL PIPELINED;
END space_tools;
/
SHOW ERR;

CREATE OR REPLACE PACKAGE BODY space_tools AS
    FUNCTION get_space_usage(owner IN VARCHAR2, object_name IN VARCHAR2, segment_type IN VARCHAR2, partition_name IN VARCHAR2 DEFAULT NULL) RETURN sys.DBMS_DEBUG_VC2COLL PIPELINED
    AS
        ufbl   NUMBER; 
        ufby   NUMBER;
        fs1bl  NUMBER;
        fs1by  NUMBER;
        fs2bl  NUMBER;
        fs2by  NUMBER;
        fs3bl  NUMBER;
        fs3by  NUMBER;
        fs4bl  NUMBER;
        fs4by  NUMBER;
        fubl   NUMBER;
        fuby   NUMBER;       
    BEGIN
        DBMS_SPACE.SPACE_USAGE(owner,object_name,segment_type, ufbl, ufby, fs1bl,fs1by, fs2bl,fs2by, fs3bl,fs3by, fs4bl,fs4by, fubl,fuby, partition_name);
        PIPE ROW('Full blocks       /MB '||TO_CHAR(fubl,  '999999999')||' '||TO_CHAR(fuby  /1048576,'999999999'));
        PIPE ROW('Unformatted blocks/MB '||TO_CHAR(ufbl,  '999999999')||' '||TO_CHAR(ufby  /1048576,'999999999'));
        PIPE ROW('Free Space      0-25% '||TO_CHAR(fs1bl, '999999999')||' '||TO_CHAR(fs1by /1048576,'999999999'));
        PIPE ROW('Free Space     25-50% '||TO_CHAR(fs2bl, '999999999')||' '||TO_CHAR(fs2by /1048576,'999999999'));
        PIPE ROW('Free Space     50-75% '||TO_CHAR(fs3bl, '999999999')||' '||TO_CHAR(fs3by /1048576,'999999999'));
        PIPE ROW('Free Space    75-100% '||TO_CHAR(fs4bl, '999999999')||' '||TO_CHAR(fs4by /1048576,'999999999'));
    END get_space_usage;
END space_tools;
/
SHOW ERR;



