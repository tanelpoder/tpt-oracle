-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


create type moats_v2_ntt as table of varchar2(4000);
/

create type moats_output_ot as object
( output varchar2(4000)
);
/

create type moats_output_ntt as table of moats_output_ot;
/

create type moats_ash_ot as object
( snaptime                      timestamp
, saddr                         raw(8)
, sid                           number
, serial#                       number
, audsid                        number
, paddr                         raw(8)
, user#                         number
, username                      varchar2(64)
, command                       number
, ownerid                       number
, taddr                         varchar2(64)
, lockwait                      varchar2(64)
, status                        varchar2(64)
, server                        varchar2(64)
, schema#                       number
, schemaname                    varchar2(64)
, osuser                        varchar2(64)
, process                       varchar2(64)
, machine                       varchar2(64)
, terminal                      varchar2(64)
, program                       varchar2(64)
, type                          varchar2(64)
, sql_address                   raw(8)
, sql_hash_value                number
, sql_id                        varchar2(64)
, sql_child_number              number
, prev_sql_addr                 raw(8)
, prev_hash_value               number
, prev_sql_id                   varchar2(64)
, prev_child_number             number
, module                        varchar2(64)
, module_hash                   number
, action                        varchar2(64)
, action_hash                   number
, client_info                   varchar2(64)
, fixed_table_sequence          number
, row_wait_obj#                 number
, row_wait_file#                number
, row_wait_block#               number
, row_wait_row#                 number
, logon_time                    date
, last_call_et                  number
, pdml_enabled                  varchar2(64)
, failover_type                 varchar2(64)
, failover_method               varchar2(64)
, failed_over                   varchar2(64)
, resource_consumer_group       varchar2(64)
, pdml_status                   varchar2(64)
, pddl_status                   varchar2(64)
, pq_status                     varchar2(64)
, current_queue_duration        number
, client_identifier             varchar2(64)
, blocking_session_status       varchar2(64)
, blocking_instance             number
, blocking_session              number
, seq#                          number
, event#                        number
, event                         varchar2(64)
, p1text                        varchar2(64)
, p1                            number
, p1raw                         raw(8)
, p2text                        varchar2(64)
, p2                            number
, p2raw                         raw(8)
, p3text                        varchar2(64)
, p3                            number
, p3raw                         raw(8)
, wait_class_id                 number
, wait_class#                   number
, wait_class                    varchar2(64)
, wait_time                     number
, seconds_in_wait               number
, state                         varchar2(64)
, service_name                  varchar2(64)
, sql_trace                     varchar2(64)
, sql_trace_waits               varchar2(64)
, sql_trace_binds               varchar2(64)
);
/

create type moats_ash_ntt as table of moats_ash_ot;
/

create type moats_stat_ot as object
( type  varchar2(100)
, name  varchar2(100)
, value number 
);
/

create type moats_stat_ntt as table of moats_stat_ot;
/


