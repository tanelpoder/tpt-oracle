-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

begin
    for i in (select value from v$parameter where name = 'user_dump_dest') loop
        execute immediate 'create or replace directory e2sn_udump as '''||i.value||'''';
    end loop;
end;
/


create or replace package e2sn_monitor as
    function get_trace_file (file_name in varchar2) return dbms_debug_vc2coll pipelined;
    function get_session_trace ( p_sid in number default sys_context('userenv','sid') ) return dbms_debug_vc2coll pipelined;
    procedure cbo_trace_on;
    procedure cbo_trace_off;
    procedure sql_trace_on (p_waits in boolean default true, p_binds in boolean default true);
    procedure sql_trace_off;

    procedure set_tracefile_identifier(p_text in varchar2);
    function trace_dump (p_exec_statement in varchar2) return dbms_debug_vc2coll pipelined;
    function test (p_select_statement in varchar2 default 'select count(*) from dba_segments') return dbms_debug_vc2coll pipelined;
end e2sn_monitor;
/


create or replace package body e2sn_monitor as

    procedure sql_trace_on (p_waits in boolean default true, p_binds in boolean default true)
    as
    begin
        execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
        --dbms_monitor.session_trace_enable(waits=>p_waits, binds=>p_binds);
    end; -- sql_trace_on

    procedure sql_trace_off
    as
    begin
        execute immediate 'alter session set events ''10046 trace name context off''';
        --dbms_monitor.session_trace_disable;
    end; -- sql_trace_off

    procedure cbo_trace_on
    as
    begin
        --dbms_output.put_line('setting 10053');
        execute immediate 'alter session set events ''10053 trace name context forever, level 1''';
        --execute immediate 'alter session set "_optimizer_trace"=all';
        --dbms_output.put_line('event 10053 set');
    end cbo_trace_on;

    procedure cbo_trace_off
    as
    begin
        execute immediate 'alter session set events ''10053 trace name context off''';
        --execute immediate 'alter session set "_optimizer_trace"=none';
    end cbo_trace_off;

    procedure set_tracefile_identifier(p_text in varchar2)
    as
    begin
        dbms_output.put_line('trci='||p_text);
        execute immediate 'alter session set tracefile_identifier='||p_text;
    end;

    function trace_dump (p_exec_statement in varchar2) return dbms_debug_vc2coll pipelined
    as
        j number;
        l_prefix varchar2(100);
    begin
        l_prefix := upper('CBOHELP_'||to_char(sysdate, 'YYYYMMDD_HH24_MI_SS'));

        set_tracefile_identifier(l_prefix);

        --cbo_trace_on;
        --sql_trace_on;

        execute immediate p_exec_statement ||' /* E2SN CBO helper: '||l_prefix||'*/ ';
        dbms_output.put_line(j);

        --sql_trace_off;
        --cbo_trace_off;

        for i in (select column_value from table(e2sn_monitor.get_session_trace)) loop
            pipe row (i.column_value);
        end loop;
    end trace_dump;

    function test (p_select_statement in varchar2 default 'select count(*) from dba_segments') return dbms_debug_vc2coll pipelined
    as
        j number;
        l_prefix varchar2(100);
    begin
        l_prefix := upper('CBOHELP_'||to_char(sysdate, 'YYYYMMDD_HH24_MI_SS'));

        set_tracefile_identifier(l_prefix);

        --cbo_trace_on;
        --sql_trace_on;

        execute immediate p_select_statement ||' /* E2SN CBO helper: '||l_prefix||'*/ ' INTO j;
        dbms_output.put_line(j);

        --sql_trace_off;
        --cbo_trace_off;

        for i in (select column_value from table(e2sn_monitor.get_session_trace)) loop
            pipe row (i.column_value);
        end loop;
    end test;
   
    function get_trace_file (file_name in varchar2) return dbms_debug_vc2coll pipelined
    as
	    invalid_file_op exception;
	    pragma exception_init(invalid_file_op, -29283);

        f     utl_file.file_type;
        line  varchar2(32767);
    begin

      dbms_output.put_line('opening file='||file_name);
      f := utl_file.fopen('E2SN_UDUMP', file_name, 'R', 32767);

      loop
        begin
            utl_file.get_line(f, line);
        exception
            when no_data_found then utl_file.fclose(f) ; exit;
            when others then utl_file.fclose(f) ; raise;
        end;

        if length(line) > 1000 then
            for i in 0..trunc(length(line)/1000) loop
                pipe row(substr(line,i*1000+1,1000));
            end loop;
        else
            pipe row(line);
        end if;

      end loop;

      return;

    exception
        when invalid_file_op then raise_application_error(-20000, 'ERROR: Unable to open tracefile. Maybe it does not exist');
    end get_trace_file;


    function get_session_trace ( p_sid in number default sys_context('userenv','sid') ) return dbms_debug_vc2coll pipelined
	as
		tracefile_name       varchar2(4000);
		tracefile_name_lower varchar2(4000);
    begin

        begin
            select par.value ||'/'||(select instance_name from v$instance) ||'_ora_'||s.suffix|| '.trc' into tracefile_name
            from 
                v$parameter par
              , (select spid||case when traceid is not null then '_'||traceid else null end suffix
                 from v$process where addr = (select paddr from v$session
                                              where sid = p_sid
                                            ) 
                ) s
            where name = 'user_dump_dest';

            select par.value ||'/'||(select lower(instance_name) from v$instance) ||'_ora_'||s.suffix|| '.trc' into tracefile_name_lower
            from 
                v$parameter par
              , (select spid||case when traceid is not null then '_'||traceid else null end suffix
                 from v$process where addr = (select paddr from v$session
                                              where sid = p_sid
                                            ) 
                ) s
            where name = 'user_dump_dest';

        exception
            when no_data_found then raise_application_error(-20000, 'ERROR: No matching SID/SERIAL# combination found');
        end;

        begin
            for i in (select column_value from table(get_trace_file( tracefile_name ))) loop
                pipe row(i.column_value);
            end loop;

    	    return;

        exception
            when others then 
            begin
                for i in (select column_value from table(get_trace_file( tracefile_name_lower ))) loop
                    pipe row(i.column_value);
                end loop;

                return;
            exception
                when others then raise_application_error(-20000, 'Unknown error: '||sqlerrm||chr(10)||dbms_utility.format_error_backtrace);
            end;
        end;

    	return;
    	
    end get_session_trace;

end e2sn_monitor;
/
show err;


-- grant execute on e2sn_monitor to public;
-- create public synonym e2sn_monitor for e2sn_monitor;

