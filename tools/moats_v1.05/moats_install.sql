-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


set define off
set pause on

prompt
prompt
prompt **************************************************************************
prompt **************************************************************************
prompt
prompt    MOATS Installer (for 10.2+ databases)
prompt    =====================================
prompt
prompt    This will install MOATS v1.0 into the current schema.
prompt
prompt    Ensure that the target schema has the necessary privileges described
prompt    in the README.txt file. 
prompt
prompt    To continue press Enter. To quit press Ctrl-C.
prompt
prompt    (c) oracle-developer.net & www.e2sn.com
prompt
prompt **************************************************************************
prompt **************************************************************************
prompt
prompt

pause

prompt Creating types...
@@moats_types.sql

prompt Creating package...
@@moats.pks
@@moats.pkb

prompt Creating view...
@@moats_views.sql

set define on
set pause off

