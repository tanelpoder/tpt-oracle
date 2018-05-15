-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DEF datafile="/u02/oradata/SOL102/ppx01.dbf"

DEF ppxuser=PPX
DEF oeuser=SOE
DEF shuser=SH
DEF ppxtablespace=PPX

PROMPT Creating the user and tablespaces...

--CREATE TABLESPACE ppx DATAFILE SIZE 100M AUTOEXTEND ON NEXT 10M;
--CREATE USER &ppxuser IDENTIFIED BY oracle DEFAULT TABLESPACE &ppxtablespace TEMPORARY TABLESPACE temp;
--GRANT create session, select any dictionary, dba TO &ppxuser;

-- Create clone tables
@range_part
@range_hash_subpart
@range_id_part

