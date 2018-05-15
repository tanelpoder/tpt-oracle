-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Bug 12345717 - ORA-600 [13013] or hang/spin from MERGE into table with added column [ID 12345717.8]
--
-- ORA-600 [13013] can occur when executing a MERGE statement
-- with an UPDATE clause into a table which has had an ADD COLUMN
-- executed against it with a DEFAULT value with add column
-- optimization enabled.
-- 
-- 
-- Rediscovery Notes:
--   ORA-600 [13013] on a MERGE SQL.
--   In some cases this problem can also show up as a spin
--    executing a MERGE SQL against a table with an added column.
--  
--   In both cases the problem can occur only if the target table has 
--   a NOT NULL added column with a default value.
--   You can check this with SQL of the form below which shows such columns:
--    select owner, object_name, name 
--      from dba_objects, col$
--     where bitand(col$.PROPERTY,1073741824)=1073741824
--       and object_id=obj#;
--  
-- Workaround
--  Set _add_col_optim_enabled=false before adding columns
--   (this can cause the ADD COLUMN DDL to take longer as
--    all rows need updating)
--  For existing tables set the parameter then rebuild the table
--   to remove any existing optimized columns.

-- DROP TABLE tab1;
-- DROP TABLE tab2;

CREATE TABLE TAB1 ( ID_NACE NUMBER(5) );
 ALTER TABLE TAB1 ADD (
   ID_INDUSTRY  NUMBER(5) DEFAULT -1 NOT NULL
 );
 insert into TAB1 values(1, 1); 
 insert into TAB1 values(2, 2); 
 
 CREATE TABLE TAB2 (
   ID_NACE      NUMBER(5),
   ID_INDUSTRY  NUMBER(5)
 );
 insert into TAB2 values(1, 3);
 commit;

MERGE /*+ LEADING(c) */
 INTO TAB1 c 
 USING (SELECT * from TAB2 b) a
 ON (c.id_nace=a.id_nace) 
 WHEN matched THEN
    UPDATE SET c.ID_INDUSTRY=a.ID_INDUSTRY;

