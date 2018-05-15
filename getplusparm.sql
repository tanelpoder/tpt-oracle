-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   getplusparm.sql
-- Purpose:     get sqlplus parameter value (such linesize, pagesize, sqlcode,
--              etc) into a sqlplus define variable
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @getplusparm [full-param-name] [def-variable-name]
-- 	        
-- Example:     @getplusparm linesize sqlplus_line_size
--              def sqlplus_line_size
--
--------------------------------------------------------------------------------

@saveset
set termout off

spool &SQLPATH/tmp/getplusparm.tmp
show &1
spool off

spool &SQLPATH/tmp/chgplusparm.tmp
prompt c/&1/def &2/
prompt c/&2 /&2=/
spool off

get &SQLPATH/tmp/getplusparm.tmp nolist
@&SQLPATH/tmp/chgplusparm.tmp
save file &SQLPATH/tmp/setplusparm.tmp replace

@&SQLPATH/tmp/setplusparm.tmp

@loadset

unset _getplusparm_tmpfile
