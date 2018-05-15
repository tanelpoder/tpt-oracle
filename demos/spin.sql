-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- metalink bug# 5245101

create table TCMDTY(CMDTY_CD VARCHAR2(4),CMDTY_DESC VARCHAR2(30));

create or replace package UGS_LKUPS is  
   TYPE T_CURSOR IS REF CURSOR;
   PROCEDURE GET_ACTIVE_CMDTYS (COMMODITIES_CURSOR IN OUT T_CURSOR); 
end ugs_lkups;
/

create or replace package body UGS_LKUPS IS   
   PROCEDURE GET_ACTIVE_CMDTYS (COMMODITIES_CURSOR IN OUT T_CURSOR) IS     
      v_commodities            T_CURSOR;
      TYPE cmdty_code_type     IS TABLE OF TCMDTY.CMDTY_CD%TYPE;
      TYPE cmdty_desc_type     IS TABLE OF TCMDTY.CMDTY_DESC%TYPE;
      t_CMDTY_CD               cmdty_code_type;
      t_CMDTY_DESC             cmdty_desc_type;
   BEGIN   
      OPEN v_commodities FOR
      SELECT CMDTY_CD, CMDTY_DESC   
      BULK COLLECT INTO t_CMDTY_CD, t_CMDTY_DESC
      FROM TCMDTY   
      ORDER  BY CMDTY_CD;
      
      COMMODITIES_CURSOR := v_commodities;
   END GET_ACTIVE_CMDTYS; 
end ugs_lkups; 
/


insert into TCMDTY values('a','aaaa'); 
insert into TCMDTY values('b','bbbb'); 
commit;

set serverout on

DECLARE   
   v_cursor  ugs_lkups.t_cursor;
   v_cmdty_cd  tcmdty.cmdty_cd%TYPE;
   v_cmdty_desc tcmdty.cmdty_desc%TYPE;   
BEGIN   
   ugs_lkups.GET_ACTIVE_CMDTYS (COMMODITIES_CURSOR => v_cursor);
   LOOP 
      FETCH v_cursor    INTO  v_cmdty_cd, v_cmdty_desc;
      EXIT WHEN v_cursor%NOTFOUND;     
      DBMS_OUTPUT.PUT_LINE(v_cmdty_cd || ' | ' || v_cmdty_desc);   
   END LOOP;
   CLOSE v_cursor;
END;
/
 