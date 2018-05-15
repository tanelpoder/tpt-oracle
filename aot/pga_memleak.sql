-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Bug 16855783 : MEMORY LEAK IN PGA ON INSERT OF XMLTYPE COLUMN
SET sqlblanklines ON;
SET serveroutput ON;
 
--drop table memleak_test_tab;
--CREATE TABLE memleak_test_tab (my_xmltype XMLTYPE);
 
DECLARE
   l_my_varchar2 VARCHAR2(4001 CHAR); -- change this to CLOB and there will be a reduced memory leak.
   --l_my_varchar2 CLOB;
   l_pga_used_mb NUMBER;
   l_dummy       NUMBER;
   l_my_xmltype  XMLTYPE;
BEGIN
   -- build XML string with length of 4001 characters.
   l_my_varchar2 := '<abc>';
   FOR i IN 1 .. (4000/20) - 10
   LOOP
       l_my_varchar2 := l_my_varchar2 || '<def>1234567890</def>';   -- reduce string size by removing final 0
   END LOOP;
   l_my_varchar2 := l_my_varchar2 || '</abc>';
   dbms_output.put_line('Input string length: [' || LENGTH(l_my_varchar2) || ']');
 
   -- repeatedly insert the same value in a table (XMLType column)
   l_my_xmltype := XMLTYPE(l_my_varchar2);
   FOR i IN 1 .. 5000
   LOOP
      -- l_my_xmltype := XMLTYPE(l_my_varchar2);
       INSERT INTO memleak_test_tab (my_xmltype)
           VALUES (l_my_xmltype);
 
       -- following insert throws ORA-1461 which I suppose is also a bug
       -- ORA-1461: can bind a LONG value only for insert into a LONG column
       -- INSERT INTO memleak_test_tab (my_xmltype)
       --     VALUES (XMLTYPE(l_my_varchar2));
   END LOOP;
 
   ROLLBACK;
 
   -- Check how much memory are we currently using
   SELECT round(p.pga_used_mem/1024/1024, 2) INTO l_pga_used_mb
   FROM v$session s
   JOIN v$process p ON p.addr = s.paddr
   WHERE s."SID"=sys_context('userenv', 'sid');
   dbms_output.put_line('Currently used PGA: [' || l_pga_used_mb || '] MB');
END;
/

