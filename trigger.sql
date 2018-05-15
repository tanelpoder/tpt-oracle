-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

create or replace trigger test
after servererror on oracle.schema
begin
  dbms_output.put_line('Error: '|| sysdate);
end;
/




declare
  cursor getDepartments is
    select xtab.name NAME, ref(d) XMLREF
    from DEPARTMENT_XQL d, xmltable(
     'for $i in . return $i/Department/Name' PASSING d.object_value
      COLUMNS name VARCHAR2(30) PATH '/Name') xtab;
  res boolean;
  targetFolder varchar2(1024) :=  '/home//OE/XQDepartments';
begin
  if dbms_xdb.existsResource(targetFolder) then
     dbms_xdb.deleteResource(targetFolder,dbms_xdb.DELETE_RECURSIVE);
  end if;
  res := dbms_xdb.createFolder(targetFolder);
  for dept in getDepartments loop
    res := DBMS_XDB.createResource(targetFolder || '/' || dept.NAME || '.xml', dept.XMLREF);
  end loop;
end;
/

