-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

define spuser=&1
define spkeep=&2

prompt

set heading off feedback off
select 'sesspack_purge: removing records older than '|| to_char( sysdate - &spkeep, 'YYYYMMDD HH24:MI:SS') from dual;
set heading on feedback on 

prompt

prompt delete from &spuser..SAWR$SNAPSHOTS where snaptime < sysdate - &spkeep;
delete from &spuser..SAWR$SNAPSHOTS where snaptime < sysdate - &spkeep;
commit;

prompt delete from &spuser..SAWR$SESSIONS where snaptime < sysdate - &spkeep;
delete from &spuser..SAWR$SESSIONS where snaptime < sysdate - &spkeep;
commit;

prompt delete from &spuser..SAWR$SESSION_EVENTS where snaptime < sysdate - &spkeep;
delete from &spuser..SAWR$SESSION_EVENTS where snaptime < sysdate - &spkeep;
commit;

prompt delete from &spuser..SAWR$SESSION_STATS where snaptime < sysdate - &spkeep;
delete from &spuser..SAWR$SESSION_STATS where snaptime < sysdate - &spkeep;
commit;

-- compact the indexes & IOTs for saving space
alter index SAWR$SNAPSHOTS_PK coalesce;
alter table SAWR$SESSIONS move online;
alter table SAWR$SESSION_STATS move online;
alter table SAWR$SESSION_EVENTS move online;

undefine spuser
undefine spkeep
