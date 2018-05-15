-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- Name:        drop_xviews.sql
-- Purpose:     Drop custom views, grants and synonyms for X$ fixed tables 
-- Usage:       Run from sqlplus as SYS: @drop_xviews.sql
-- 
--
-- Author:      (c) Tanel Poder http://www.tanelpoder.com
-- 
-- Other:       Note that this script only generatesd drop commands for manual 
--		execution. Make sure that you don't drop any X$ tables required 
--		by other software like StatsPack and monitoring tools
--
--------------------------------------------------------------------------------

@saveset

set pagesize 0
set linesize 200
set trimspool on
set feedback off

Prompt Generating drop script...

spool drop_xviews.tmp

set termout off

select 'drop view '||object_name||';' 
from (
    select object_name 
    from dba_objects 
    where owner = 'SYS' 
    and object_name like 'X\_$%' escape '\' 
);

select 'drop public synonym '||synonym_name||';' 
from (
    select synonym_name 
    from dba_synonyms 
    where owner = 'PUBLIC' 
    and synonym_name like 'X$%' 
);

spool off

set termout on

Prompt Done generating drop script.
Prompt Now review and manually execute the file drop_xviews.tmp using @drop_xviews.tmp
Prompt

@loadset
