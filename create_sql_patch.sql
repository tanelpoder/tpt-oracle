-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- you can query patch info from DBA_SQL_PATCHES
-- the actual hints can be seen using: 
--   select comp_data from sqlobj$data;
-- 
-- a sql patch can be dropped with:
-- dbms_sqldiag.drop_sql_patch('&patch_name');
--
-- Note that it's best to use manual hinting first and if the hint works, extract it in its full 
-- format from the OUTLINE section of the plan. for example, I had to use this format:
--
--     FULL(@"SEL$1" "T"@"SEL$1")
-- 
-- ... instead of just FULL(t) to make the patch work (12.1)
--
-- The DBMS_SQLDIAG_INTERNAL.I_CREATE_PATCH actually requires the SQL Text (as a CLOB) instead of just
-- the SQL_ID, in 12.1 and earlier this script fetches the SQL Text from v$sql (the cursor needs 
-- to be in library cache). Similarly the DBMS_SQLDIAG.CREATE_PATCH(sql_id=>...) needs the cursor to be
-- in library cache in order to find the corresponding SQL text.

SET SERVEROUT ON SIZE 1000000

DECLARE
    v_sql_text  CLOB;
    ret         VARCHAR2(100);
BEGIN
    -- rownum = 1 because there may be multiple children with this SQL_ID
    DBMS_OUTPUT.PUT_LINE(q'[Looking up SQL_ID &1]');
    SELECT sql_fulltext INTO v_sql_text FROM v$sql WHERE sql_id = '&1' AND rownum = 1;
    DBMS_OUTPUT.PUT_LINE('Found: '||SUBSTR(v_sql_text,1,80)||'...');

    -- TODO: should use PL/SQL conditional compilation here 
    -- The leading space in hint_text is intentional.

    -- 12.2+
    ret := DBMS_SQLDIAG.CREATE_SQL_PATCH(sql_id=>'&1', hint_text=>q'[ &2]', name=>'SQL_PATCH_&1');

    -- 11g and 12.1
    --DBMS_SQLDIAG_INTERNAL.I_CREATE_PATCH(sql_text=>v_sql_text, hint_text=>q'[ &2]', name=>'SQL_PATCH_&1');
    DBMS_OUTPUT.PUT_LINE(q'[SQL Patch Name = SQL_PATCH_&1]');
END;
/

SET SERVEROUT OFF

