-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


set define off
set pause on

prompt
prompt
prompt **************************************************************************
prompt **************************************************************************
prompt
prompt    MOATS Uninstaller
prompt    =================
prompt
prompt    This will uninstall MOATS.
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

prompt Removing MOATS...

drop view top;
drop package moats;
drop type moats_output_ntt;
drop type moats_output_ot;
drop type moats_v2_ntt;
drop type moats_ash_ntt;
drop type moats_ash_ot;
drop type moats_stat_ntt;
drop type moats_stat_ot;

prompt
prompt
prompt **************************************************************************
prompt    Uninstall complete.
prompt **************************************************************************

