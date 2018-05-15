-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--
-- SCRIPT:  session_wait_monitor.sql
--
-- PURPOSE: Creates one table and one procedure for logging v$session_wait 
--          wait statistics. Running this script does not enable the logging,
--          the usage examples are below.
--
-- REQUIREMENTS:
--          Read access on V$SESSION_WAIT
--          Execute right on DBMS_LOCK
--
-- USAGE:
--          EXEC session_wait_monitor ( <wait_name>, <from_time>, <to_time>, <sleep_time> )
--
--          wait_name = the name of wait event to be sampled, % and _ wildcards allowed, default %
--          from_time = time when sampling should start (the procedure sleeps until then), default SYSDATE
--          to_time   = time when sampling should end (procedure quits then), default SYSDATE + 1 minute
--          sleep_time= time to sleep between samples, default 5 seconds
--
--          once the procedure returns, query session wait samples:
--
--          SELECT * FROM session_wait_hist ORDER BY sample_time ASC, cnt DESC;
--
-- EXAMPLES:
-- After the table and procedure have been created, use following commands to:
--
-- 1) Sample all session waits for 60 seconds from now, at 5 second intervals (few idle waits are not sampled):
--
--      EXEC session_wait_monitor
--
-- 2) Sample only buffer busy waits from 9 pm to 9:10 pm on 2007-10-19 (3 second sampling interval)
--
--      EXEC session_wait_monitor('buffer busy waits', timestamp'2007-10-19 21:00:00', timestamp'2007-10-19 21:10:00', 3)
--
-- 3) Sample all events containing "db" from now up to end of today:
--      
--      EXEC session_wait_monitor('%db%', sysdate, trunc(sysdate)+1)
--

create table session_wait_hist(
    sample_time date            not null, 
    event       varchar2(100)   not null, 
    p1          number,
    p2          number, 
    p3          number, 
    cnt         number
);

create or replace procedure session_wait_monitor ( 
                    wait_name   in varchar2 default '%', 
                    from_time   in date     default sysdate,
                    to_time     in date     default sysdate + 1/24/60,
                    sleep_time  in number   default 5
) 
    authid current_user as
begin
    
    while sysdate < from_time loop
        dbms_lock.sleep(sleep_time);    
    end loop;

    while sysdate between from_time and to_time loop

        insert into 
            session_wait_hist       
        select 
            sysdate, event, p1, p2, p3, count(*) cnt 
        from 
            v$session_wait 
        where 
            state = 'WAITING' 
        and event like wait_name
        and event not in (
            'SQL*Net message from client',
            'pmon timer',
            'rdbms ipc message',
            'smon timer',
            'wakeup time manager'
        )
        group by 
            event, p1, p2, p3;

        commit;
        
        dbms_lock.sleep(sleep_time);    
    
    end loop;
    
end;
/
