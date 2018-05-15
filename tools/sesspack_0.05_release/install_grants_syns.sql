-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- Author:	Tanel Poder
-- Copyright:	(c) http://www.tanelpoder.com
-- 
-- Notes:	This software is provided AS IS and doesn't guarantee anything
-- 		Proofread before you execute it!
--
--------------------------------------------------------------------------------


-- grants for procs & types
grant execute on sesspack to sesspack_user_role;
grant execute on sawr$sidlist to sesspack_user_role;

-- grants for sequences
grant select on sawr$snapid_seq to sesspack_user_role;

-- grants for tables
grant select, insert on sawr$snapshots 		to sesspack_user_role;
grant select, insert on sawr$sessions 		to sesspack_user_role;
grant select, insert on sawr$session_events 	to sesspack_user_role;
grant select, insert on sawr$session_stats 	to sesspack_user_role;
grant select         on sawr$session_stat_mode 	to sesspack_user_role;

-- grants for views
grant select on sawr$sess_event to sesspack_user_role;
--grant select on sawr$sess_event_delta to sesspack_user_role;
grant select on sawr$sess_stat to sesspack_user_role;

-- synonyms for procs & types
create public synonym sesspack for sesspack;
create public synonym sawr$sidlist for sawr$sidlist;

-- synonyms for sequences
create public synonym sawr$snapid_seq for sawr$snapid_seq;

-- synonyms for tables
create public synonym sawr$snapshots for sawr$snapshots;
create public synonym sawr$sessions for sawr$sessions;
create public synonym sawr$session_events for sawr$session_events;
create public synonym sawr$session_stats for sawr$session_stats;
create public synonym sawr$session_stat_mode for sawr$session_stat_mode;

-- synonyms for views
create public synonym sawr$sess_event for sawr$sess_event;
--create public synonym sawr$sess_event_delta for sawr$sess_event_delta;
create public synonym sawr$sess_stat for sawr$sess_stat;

