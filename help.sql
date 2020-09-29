-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


--------------------------------------------------------------------------------
--
-- File name:   help.sql
-- Purpose:     Help
-- Author:      Tomasz Sroka
-- Usage:       @help <string>
--
--------------------------------------------------------------------------------
--ACCEPT search_string CHAR PROMPT "Search: [%] "

DEFINE amp=chr(38)
DEFINE nl=chr(10)
DEFINE search_string=&1

COLUMN name FORMAT A25 TRUNC
COLUMN description FORMAT A60 WORD_WRAP
COLUMN usage FORMAT A115

WITH q AS (
SELECT name, description, usage
FROM (
  SELECT 'ash_wait_chains.sql' AS name, 'Display ASH wait chains (multi-session wait signature, a session waiting for another session etc.)' AS description, '@ash/ash_wait_chains <grouping_cols> <filters> <from_time> <to_time>'||&nl||'@ash/ash_wait_chains username||''-''||program2 "wait_class=''Application''" sysdate-1/24 sysdate' AS usage FROM dual UNION ALL
  SELECT 'ash_index_helper.sql' AS name, 'Santa''s Little (Index) Helper BETA' AS description, '@ash/ash_index_helper <sql_id> [<owner>.]<table_name> <from_time> <to_time>'||&nl||'@ash/ash_index_helper 8zz6y2yzdqjp0 %.% sysdate-1/24 sysdate'||&nl||'@ash/ash_index_helper % TPCDS.% sysdate-1/24 sysdate' AS usage FROM dual UNION ALL
  SELECT 'ashtop.sql' AS name, 'Display top activity by grouping ASH columns' AS description, '@ash/ashtop <grouping_cols> <filters> <from_time> <to_time>'||&nl||'@ash/ashtop username,sql_opname,event2 1=1 sysdate-1/24 sysdate'||&nl||'@ash/ashtop sql_opname,event2,sql_plan_operation||chr(32)||sql_plan_options,objt 1=1 sysdate-1/24 sysdate' AS usage FROM dual UNION ALL
  SELECT 'asqlmon.sql' AS name, 'Report SQL-monitoring-style drill-down into where in an execution plan the execution time is spent (ASH based)' AS description, '@ash/asqlmon <sql_id> <child#> <from_time> <to_time>'||&nl||'@ash/asqlmon 7q729nhdgtsqq 0 sysdate-1/24 sysdate'||&nl||'@ash/asqlmon 7q729nhdgtsqq % sysdate-1 sysdate' AS usage FROM dual UNION ALL
  SELECT 'aw.sql' AS name, 'Display last minute database activity' AS description, '@aw <filter_expression>'||&nl||'@aw 1=1' AS usage FROM dual UNION ALL
  SELECT 'awr_sqlid.sql' AS name, 'Display SQL text from AWR' AS description, '@awr/awr_sqlid <sql_id>'||&nl||'@awr/awr_sqlid 7q729nhdgtsqq' AS usage FROM dual UNION ALL
  SELECT 'awr_sqlstats.sql' AS name, 'Display SQL statistics from AWR' AS description, '@awr/awr_sqlstats <sql_id> <plan_hash_value> <from_time> <to_time>'||&nl||'@awr/awr_sqlstats 0sh0fn7r21020 1541789278 sysdate-7 sysdate'||&nl||'@awr/awr_sqlstats 0sh0fn7r21020 % sysdate-7 sysdate' AS usage FROM dual UNION ALL
  SELECT 'awr_sqlstats_per_exec.sql' AS name, 'Display SQL statistics per execution from AWR' AS description, '@awr/awr_sqlstats_per_exec <sql_id> <plan_hash_value> <from_time> <to_time>'||&nl||'@awr/awr_sqlstats_per_exec 0sh0fn7r21020 1541789278 sysdate-7 sysdate'||&nl||'@awr/awr_sqlstats_per_exec 0sh0fn7r21020 % sysdate-7 sysdate' AS usage FROM dual UNION ALL
  SELECT 'awr_sqlstats_unstable.sql' AS name, 'Display unstable SQL execution plans from AWR' AS description, '@awr/awr_sqlstats_unstable <group_by_expr1> <group_by_expr2> <from_time> <to_time>'||&nl||'@awr/awr_sqlstats_unstable force_matching_signature plan_hash_value sysdate-7 sysdate' AS usage FROM dual UNION ALL
  SELECT 'bg.sql' AS name, 'Display background processes' AS description, '@bg <process_name|process_description>'||&nl||'@bg dbw'||&nl||'@bg writer'||&nl||'@bg %' AS usage FROM dual UNION ALL
  SELECT 'bhobjects.sql' AS name, 'Display top objects in buffer cache' AS description, '@bhobjects' AS usage FROM dual UNION ALL
  SELECT 'bhobjects2.sql' AS name, 'Display buffer cache statistics' AS description, '@bhobjects2' AS usage FROM dual UNION ALL
  SELECT 'cancel.sql' AS name, 'Generate commands for canceling selected SQL' AS description, '@cancel <filter_expression>'||&nl||'@cancel sid=150'||&nl||'@cancel username=''SYSTEM'''||&nl||'@cancel "username=''APP'' and program like ''sqlplus%''"' AS usage FROM dual UNION ALL
  SELECT 'col.sql' AS name, 'Display column' AS description, '@col <column_name>'||&nl||'@col open_mode' AS usage FROM dual UNION ALL
  SELECT 'colusage.sql' AS name, 'Display column usage' AS description, '@colusage [<owner>.]<table_name>'||&nl||'@colusage soe.orders'||&nl||'@colusage soe.%' AS usage FROM dual UNION ALL
  SELECT 'create_sql_baseline.sql' AS name, 'Create SQL Plan Baseline from an existing "good" cursor' AS description, '@create_sql_baseline <good_sqlid> <good_plan_hash_value> <to_bad_sqlid>'||&nl||'@create_sql_baseline g5tuxh82pk3qf 2966233522 d7khnbh6c9qas' AS usage FROM dual UNION ALL
  SELECT 'create_sql_patch.sql' AS name, 'Create SQL patch' AS description, '@create_sql_patch <sql_id> <hint>'||&nl||'@create_sql_patch g4pkmrqrgxg3b GATHER_PLAN_STATISTICS'||&nl||q'[@create_sql_patch b9dmj0ahu6xgc 'NO_INDEX_SS(@"SEL$26CA4453" "STORE_SALES"@"SEL$1")']' AS usage FROM dual UNION ALL
  SELECT 'd.sql' AS name, 'Display data dictionary views and x$ tables' AS description, '@d <object_name>'||&nl||'@d sql'||&nl||'@d %' AS usage FROM dual UNION ALL
  SELECT 'dash_wait_chains.sql' AS name, 'Display ASH (based on DBA_HIST) wait chains (multi-session wait signature, a session waiting for another session etc.)' AS description, '@ash/dash_wait_chains <grouping_cols> <filters> <from_time> <to_time>'||&nl||'@ash/dash_wait_chains username||''-''||program2 "wait_class=''Application''" sysdate-1/24 sysdate' AS usage FROM dual UNION ALL
  SELECT 'dashtop.sql' AS name, 'Display top activity by grouping ASH columns (based on DBA_HIST)' AS description, '@ash/dashtop <grouping_cols> <filters> <from_time> <to_time>'||&nl||'@ash/dashtop username,sql_opname,event2 1=1 sysdate-1/24 sysdate'||&nl||'@ash/dashtop sql_opname,event2,sql_plan_operation||chr(32)||sql_plan_options,objt 1=1 sysdate-1 sysdate' AS usage FROM dual UNION ALL
  SELECT 'dasqlmon.sql' AS name, 'Report SQL-monitoring-style drill-down into where in an execution plan the execution time is spent (AWR based)' AS description, '@ash/dasqlmon <sqlid> <plan_hash_value> <from_time> <to_time>'||&nl||'@ash/dasqlmon 7q729nhdgtsqq 0 "timestamp''2019-10-07 07:00:00''" "timestamp''2019-10-07 07:00:00''"'||&nl||'@ash/dasqlmon 7q729nhdgtsqq % sysdate-1 sysdate' AS usage FROM dual UNION ALL
  SELECT 'date.sql' AS name, 'Display current date' AS description, '@date'||&nl||'@d sql'||&nl||'@d %' AS usage FROM dual UNION ALL
  SELECT 'ddl.sql' AS name, 'Extracts DDL statements for specified objects' AS description, '@ddl [<owner>.]<object_name>'||&nl||'@ddl sys.dba_users'||&nl||'@ddl sys.%tab%' AS usage FROM dual UNION ALL
  SELECT 'desc.sql' AS name, 'Describe object' AS description, '@desc <object_name>'||&nl||'@desc dba_tables' AS usage FROM dual UNION ALL
  SELECT 'devent_hist.sql' AS name, 'Display a histogram of the number of waits from AWR (milliseconds)' AS description, '@ash/devent_hist.sql <event> <filter_expression> <from_time> <to_time>'||&nl||'@ash/devent_hist.sql log_file 1=1 sysdate-1/24 sysdate'||&nl||'@ash/devent_hist.sql log.file|db.file "wait_class=''User I/O'' AND session_type=''FOREGROUND''" sysdate-1/24 sysdate' AS usage FROM dual UNION ALL
  SELECT 'df.sql' AS name, 'Display tablespace usage (GB)' AS description, '@df' AS usage FROM dual UNION ALL
  SELECT 'dfm.sql' AS name, 'Display tablespace usage (MB)' AS description, '@dfm' AS usage FROM dual UNION ALL
  SELECT 'dirs.sql' AS name, 'Display database directories' AS description, '@dirs' AS usage FROM dual UNION ALL
  SELECT 'drop_sql_patch.sql' AS name, 'Drop SQL patch' AS description, '@drop_sql_patch <patch_name>'||&nl||'@drop_sql_patch SQL_PATCH_g4pkmrqrgxg3b' AS usage FROM dual UNION ALL
  SELECT 'drop_sql_baseline.sql' AS name, 'Drop SQL Plan Baseline' AS description, '@drop_sql_baseline <sql_handle>   (get sql_handle from DBMS_XPLAN notes or DBA_SQL_PLAN_BASELINES)'||&nl||'@drop_sql_baseline SQL_52cb74b7097edbbd' AS usage FROM dual UNION ALL
  SELECT 'ev.sql' AS name, 'Set session event' AS description, '@ev <event> <level>'||&nl||'@ev 10046 12' AS usage FROM dual UNION ALL
  SELECT 'event_hist.sql' AS name, 'Display a histogram of the number of waits from ASH (milliseconds)' AS description, '@ash/event_hist.sql <event> <filter_expression> <from_time> <to_time>'||&nl||'@ash/event_hist.sql log.file 1=1 sysdate-1/24 sysdate'||&nl||'@ash/event_hist.sql log.file|db.file "wait_class=''User I/O'' AND session_type=''FOREGROUND''" sysdate-1/24 sysdate' AS usage FROM dual UNION ALL
  SELECT 'event_hist_micro.sql' AS name, 'Display a histogram of the number of waits from ASH (microseconds)' AS description, '@ash/event_hist_micro <event> <filter_expression> <from_time> <to_time>'||&nl||'@ash/event_hist_micro log.file 1=1 sysdate-1/24 sysdate'||&nl||'@ash/event_hist_micro log.file|db.file "wait_class=''User I/O'' AND session_type=''FOREGROUND''" sysdate-1/24 sysdate' AS usage FROM dual UNION ALL
  SELECT 'evh.sql' AS name, 'Display a histogram of the number of waits' AS description, '@evh <event>'||&nl||'@evh log.file'||&nl||'@evh log.file|db.file' AS usage FROM dual UNION ALL
  SELECT 'evo.sql' AS name, 'Disable session event' AS description, '@evo <event>'||&nl||'@evo 10046' AS usage FROM dual UNION ALL
  SELECT 'fix.sql' AS name, 'Display fix controls description' AS description, '@fix <bugno|description|optimizer_feature_enable|sql_feature>'||&nl||'@fix 13836796'||&nl||'@fix adaptive' AS usage FROM dual UNION ALL
  SELECT 'grp.sql' AS name, 'Group function wrapper' AS description, '@grp <column_name> <table_name>'||&nl||'@grp owner dba_tables'||&nl||'@grp owner,object_type dba_objects' AS usage FROM dual UNION ALL
  SELECT 'help.sql' AS name, 'Display TPT script help' AS description, '@help <search_expression>'||&nl||'@help explain'||&nl||'@help lock|latch.*hold'||&nl||'@help ^ind.*sql|^tab.*sql' AS usage FROM dual UNION ALL
  SELECT 'hash.sql' AS name, 'Display the hash value, sql_id, and child number of the last SQL in session' AS description, '@hash' AS usage FROM dual UNION ALL
  SELECT 'hint.sql' AS name, 'Display all available hints' AS description, '@hint <name>'||&nl||'@hint full' AS usage FROM dual UNION ALL
  SELECT 'hintclass.sql' AS name, 'Display all available hints with hint class info' AS description, '@hintclass <hint_name>'||&nl||'@hintclass merge' AS usage FROM dual UNION ALL
  SELECT 'hintfeature.sql' AS name, 'Display all available hints with SQL feature info' AS description, '@hintfeature <feature_name>'||&nl||'@hintfeature transformation' AS usage FROM dual UNION ALL
  SELECT 'hinth.sql' AS name, 'Display hint hierarchy' AS description, '@hinth <hint_name>'||&nl||'@hinth merge' AS usage FROM dual UNION ALL
  SELECT 'ind.sql' AS name, 'Display indexes' AS description, '@ind [<owner>.]<index_name|table_name>'||&nl||'@ind orders'||&nl||'@ind soe.ord_customer_ix'||&nl||'@ind soe.%' AS usage FROM dual UNION ALL
  SELECT 'indf.sql' AS name, 'Display function-based index expressions' AS description, '@indf [<owner>.]<index_name|table_name>'||&nl||'@indf orders'||&nl||'@indf soe.ord_customer_ix'||&nl||'@indf soe.%' AS usage FROM dual UNION ALL
  SELECT 'kill.sql' AS name, 'Generate command to for killing user session' AS description, '@kill <filter_expression>'||&nl||'@kill sid=284'||&nl||'@kill username=''SYSTEM'''||&nl||'@kill "username=''APP'' AND program LIKE ''sqlplus%''"' AS usage FROM dual UNION ALL
  SELECT 'latchprof.sql' AS name, 'Profile top latch holders (V$ version)' AS description, '@latchprof <grouping_columns> <sid> <latch_name> <samples>'||&nl||'@latchprof name,sqlid 123 % 10000'||&nl||'@latchprof sid,name,sqlid % "shared pool" 10000' AS usage FROM dual UNION ALL
  SELECT 'latchprofx.sql' AS name, 'Profile top latch holders eXtended (X$ version)' AS description, '@latchprofx <grouping_columns> <sid> <latch_name> <samples>'||&nl||'@latchprofx sid,name 123 % 10000'||&nl||'@latchprofx sid,name,timemodel,hmode,func % "shared pool" 10000' AS usage FROM dual UNION ALL
  SELECT 'lock.sql' AS name, 'Display current locks' AS description, '@lock <filter_expression>'||&nl||'@lock 1=1'||&nl||'@lock type=''TM''' AS usage FROM dual UNION ALL
  SELECT 'log.sql' AS name, 'Display redo log layout' AS description, '@log' AS usage FROM dual UNION ALL
  SELECT 'long.sql' AS name, 'Display session long operations' AS description, '@long <filter_expression>'||&nl||'@long 1=1'||&nl||'@long username=''SOE''' AS usage FROM dual UNION ALL
  SELECT 'ls.sql' AS name, 'Display tablespace' AS description, '@ls <tablespace_name>'||&nl||'@ls system'||&nl||'@ls %' AS usage FROM dual UNION ALL
  SELECT 'lt.sql' AS name, 'Display lock type info' AS description, '@lt <lock_name>'||&nl||'@lt TM' AS usage FROM dual UNION ALL
  SELECT 'mem.sql' AS name, 'Display information about the dynamic SGA components' AS description, '@mem' AS usage FROM dual UNION ALL
  SELECT 'memres.sql' AS name, 'Display information about the last completed memory resize operations' AS description, '@memres' AS usage FROM dual UNION ALL
  SELECT 'nonshared.sql' AS name, 'Display reasons for non-shared child cursors from v$shared_cursor', '@nonshared <sql_id>'||&nl||'@nonshared 7q729nhdgtsqq' AS usage FROM dual UNION ALL
  SELECT 'nls.sql' AS name, 'Display NLS parameters at session level', '@nls' AS usage FROM dual UNION ALL
  SELECT 'o.sql' AS name, 'Display database object based on object owner and name', '@o [<owner>.]<object_name>'||&nl||'@o sys.dba_users'||&nl||'@o %.%files' AS usage FROM dual UNION ALL
  SELECT 'oda.sql' AS name, 'Display oradebug doc event action', '@oda <action>'||&nl||'@oddc latch'||&nl||'@oddc .' AS usage FROM dual UNION ALL
  SELECT 'oddc.sql' AS name, 'Display oradebug doc component', '@oddc <component>'||&nl||'@oddc optimizer'||&nl||'@oddc .' AS usage FROM dual UNION ALL
  SELECT 'oerr.sql' AS name, 'Display Oracle error decription' AS description, '@oerr <error_number>'||&nl||'@oerr 7445' AS usage FROM dual UNION ALL
  SELECT 'oi.sql' AS name, 'Display invalid objects' AS description, '@oi' AS usage FROM dual UNION ALL
  SELECT 'oid.sql' AS name, 'Display database objects based on object id' AS description, '@oid <object_id>'||&nl||'@oid 10'||&nl||'@oid 10,20' AS usage FROM dual UNION ALL
  SELECT 'otherxml.sql' AS name, 'Display outline hints from library cache' AS description, '@otherxml <sql_id> <child#>'||&nl||'@otherxml 1fbwxvngasv1f 1' AS usage FROM dual UNION ALL
  SELECT 'p.sql' AS name, 'Display parameter name and value' AS description, '@p <parameter_name>'||&nl||'@pd optimizer' AS usage FROM dual UNION ALL
  SELECT 'partkeys.sql' AS name, 'Display table partition keys' AS description, '@partkeys [<owner>.]<table_name>'||&nl||'@partkeys soe.orders'||&nl||'@partkeys soe.%' AS usage FROM dual UNION ALL
  SELECT 'pd.sql' AS name, 'Display parameter name, description and value' AS description, '@pd <parameter_description>'||&nl||'@pd optimizer' AS usage FROM dual UNION ALL
  SELECT 'pga.sql' AS name, 'Display PGA memory usage statistics' AS description, '@pga' AS usage FROM dual UNION ALL
  SELECT 'pmem.sql' AS name, 'Display process memory usage' AS description, '@pmem <spid>'||&nl||'@pmem 1000' AS usage FROM dual UNION ALL
  SELECT 'proc.sql' AS name, 'Display functions and procedures' AS description, '@proc <object_name> <procedure_name>'||&nl||'@proc dbms_stats table'||&nl||'@proc dbms_stats %' AS usage FROM dual UNION ALL
  SELECT 'procid.sql' AS name, 'Display functions and procedures' AS description, '@procid <object_id> <subprogram_id>'||&nl||'@procid 13615 84' AS usage FROM dual UNION ALL
  SELECT 'pv.sql' AS name, 'Display parameters based on the current value' AS description, '@pv <value>'||&nl||'@pv MANUAL' AS usage FROM dual UNION ALL
  SELECT 'pvalid.sql' AS name, 'Display valid parameter values' AS description, '@pvalid <parameter_name>'||&nl||'@pvalid optimizer' AS usage FROM dual UNION ALL
  SELECT 'rowid.sql' AS name, 'Display file, block, row numbers from rowid' AS description, '@rowid <rowid>'||&nl||'@rowid AAAR51AAMAAAACGAAB' AS usage FROM dual UNION ALL
  SELECT 's.sql' AS name, 'Display current session wait and SQL_ID info (10g+)' AS description, '@s <sid>'||&nl||'@s 52,110,225'||&nl||'@s "select sid from v$session where username = ''XYZ''"'||&nl||'@s '||&amp||'mysid' AS usage FROM dual UNION ALL
  SELECT 'sdr.sql' AS name, 'Control direct read in serial (_serial_direct_read)' AS description, '@sdr <TRUE|FALSE>' AS usage FROM dual UNION ALL
  SELECT 'se.sql' AS name, 'Display session events' AS description, '@se <sid>'||&nl||'@se 10' AS usage FROM dual UNION ALL
  SELECT 'sed.sql' AS name, 'Display wait events description' AS description, '@sed <event>'||&nl||'@sed log_file'||&nl||'@sed "enq: TX"' AS usage FROM dual UNION ALL
  SELECT 'seg.sql' AS name, 'Display segment information' AS description, '@seg [<owner>.]<segment_name>'||&nl||'@seg soe.customers'||&nl||'@seg soe.%' AS usage FROM dual UNION ALL
  SELECT 'segcached.sql' AS name, 'Display number of buffered blocks of a segment' AS description, '@segcached [<owner>.]<object_name>'||&nl||'@segcached soe.orders'||&nl||'@segcached soe.%' AS usage FROM dual UNION ALL
  SELECT 'seq.sql' AS name, 'Display sequence information' AS description, '@seq [<owner>.]<sequence_name>'||&nl||'@seq sys.jobseq'||&nl||'@seq %.jobseq' AS usage FROM dual UNION ALL
  SELECT 'ses.sql' AS name, 'Display session statistics for given sessions, filter by statistic name' AS description, '@ses <sid> <statname>'||&nl||'@ses 10 %'||&nl||'@ses 10 parse'||&nl||'@ses 10,11,12 redo'||&nl||'@ses "select sid from v$session where username = ''APPS''" parse' AS usage FROM dual UNION ALL
  SELECT 'ses2.sql' AS name, 'Display session statistics for given sessions, filter by statistic name and show only stats with value > 0' AS description, '@ses2 <sid> <statname>'||&nl||'@ses2 10 %'||&nl||'@ses2 10 parse'||&nl||'@ses2 10,11,12 redo'||&nl||'@ses2 "select sid from v$ses2sion where username = ''APPS''" parse' AS usage FROM dual UNION ALL
  SELECT 'settings.sql' AS name, 'Display AWR configuration' AS description, '@awr/settings' AS usage FROM dual UNION ALL
  SELECT 'sga.sql' AS name, 'Display instance memory usage breakdown from v$memory_dynamic_components' AS description, '@sga' AS usage FROM dual UNION ALL
  SELECT 'sgai.sql' AS name, 'Display instance memory usage breakdown from v$sgainfo' AS description, '@sgai' AS usage FROM dual UNION ALL
  SELECT 'sgares.sql' AS name, 'Display information about the last completed SGA resize operations from v$sga_resize_ops' AS description, '@sgares' AS usage FROM dual UNION ALL
  SELECT 'sgastat.sql' AS name, 'Display detailed information on the SGA from v$sgastat' AS description, '@sgastat <name|pool>'||&nl||'@sgastat %'||&nl||'@sgastat result' AS usage FROM dual UNION ALL
  SELECT 'sgastatx.sql' AS name, 'Display shared pool stats by sub-pool from X$KSMSS' AS description, '@sgastatx <statistic_name>'||&nl||'@sgastatx "free memory"'||&nl||'@sgastatx cursor' AS usage FROM dual UNION ALL
  SELECT 'sys.sql' AS name, 'Display system statistics' AS description, '@sys <statistic_name>'||&nl||'@sys redo'||&nl||'@sys ''redo write''' AS usage FROM dual UNION ALL
  SELECT 'uu.sql' AS name, 'Display user sessions' AS description, '@uu <username>'||&nl||'@uu %'||&nl||'@uu username'||&nl||'@uu %username%' AS usage FROM dual UNION ALL
  SELECT 'us.sql' AS name, 'Display database usernames from dba_users' AS description, '@us <username>'||&nl||'@us username' AS usage FROM dual UNION ALL
  SELECT 'usid.sql' AS name, 'Display user sessoin and process information' AS description, '@usid <sid>'||&nl||'@us 1234' AS usage FROM dual UNION ALL
  SELECT 'sl.sql' AS name, 'Set statistics level' AS description, '@sl <statistics_level>'||&nl||'@sl all' AS usage FROM dual UNION ALL
  SELECT 'smem.sql' AS name, 'Display process memory usage' AS description, '@smem <sid>'||&nl||'@smem 1000' AS usage FROM dual UNION ALL
  SELECT 'sqlbinds.sql' AS name, 'Display captured SQL bind variable values' AS description, '@sqlbinds <sql_id> <child_number>'||&nl||'@sqlbinds 2swu3tn1ujzq7 0'||&nl||'@sqlbinds 2swu3tn1ujzq7 %' AS usage FROM dual UNION ALL
  SELECT 'sqlid.sql' AS name, 'Display SQL: text, child cursors and execution statistics' AS description, '@sqlid <sql_id> <child_number>'||&nl||'@sqlid 7q729nhdgtsqq 0'||&nl||'@sqlid 7q729nhdgtsqq %' AS usage FROM dual UNION ALL
  SELECT 'sqlf.sql' AS name, 'Display full sql text from memory' AS description, '@sqlf <sql_id>'||&nl||'@sqlf 7q729nhdgtsqq' AS usage FROM dual UNION ALL
  SELECT 'sqlfn.sql' AS name, 'Display SQL functions' AS description, '@sqlf <name>'||&nl||'@sqlfn date' AS usage FROM dual UNION ALL
  SELECT 'sqlmon.sql' AS name, 'Run SQL Monitor report' AS description, '@sqlmon <sid>'||&nl||'@sqlmon 1019' AS usage FROM dual UNION ALL
  SELECT 'syn.sql' AS name, 'Display synonym information' AS description, '@syn [<owner>.]<synonym_name>'||&nl||'@syn system.tab'||&nl||'@syn system.%' AS usage FROM dual UNION ALL
  SELECT 't.sql' AS name, 'Display default trace file' AS description, '@t' AS usage FROM dual UNION ALL
  SELECT 'tab.sql' AS name, 'Display table information' AS description, '@tab [<owner>.]<table_name>'||&nl||'@tab soe.orders'||&nl||'@tab soe.%' AS usage FROM dual UNION ALL
  SELECT 'tabhist.sql' AS name, 'Display column histograms' AS description, '@tabhist [<owner>.]<table_name> <column_name>'||&nl||'@tabhist soe.orders order_mode'||&nl||'@tabhist soe.orders %' AS usage FROM dual UNION ALL
  SELECT 'tabpart.sql' AS name, 'Display table partitions' AS description, '@tabpart [<owner>.]<table_name>'||&nl||'@tabpart soe.orders'||&nl||'@tabpart soe.%' AS usage FROM dual UNION ALL
  SELECT 'tabsubpart' AS name, 'Display table subpartitions' AS description, '@tabsubpart [<owner>.]<table_name>'||&nl||'@tabsubpart soe.orders'||&nl||'@tabsubpart soe.%' AS usage FROM dual UNION ALL
  SELECT 'ti.sql' AS name, 'Force new trace file' AS description, '@ti' AS usage FROM dual UNION ALL
  SELECT 'tlc.sql' AS name, 'Display top-level call names' AS description, '@tlc <call_name>'||&nl||'@tlc commit' AS usage FROM dual UNION ALL
  SELECT 'topseg.sql' AS name, 'Display top space users per tablespace' AS description, '@topseg <tablespace_name>'||&nl||'@topseg soe'||&nl||'@topseg %' AS usage FROM dual UNION ALL
  SELECT 'topsegstat.sql' AS name, 'Display information about top segment-level statistics' AS description, '@topsegstat <statistic_name>'||&nl||'@topsegstat reads'||&nl||'@topsegstat %' AS usage FROM dual UNION ALL
  SELECT 'trace.sql' AS name, 'Enable tracing' AS description, '@trace <filter_expression>'||&nl||'@trace sid=123'||&nl||'@trace username=''SOE''' AS usage FROM dual UNION ALL
  SELECT 'traceme.sql' AS name, 'Enable tracing for the current session' AS description, '@traceme' AS usage FROM dual UNION ALL
  SELECT 'traceoff.sql' AS name, 'Disable tracing' AS description, '@traceoff <filter_expression>'||&nl||'@traceoff sid=123'||&nl||'@traceoff username=''SOE''' AS usage FROM dual UNION ALL
  SELECT 'trans.sql' AS name, 'Display active transactions' AS description, '@trans' AS usage FROM dual UNION ALL
  SELECT 'trig.sql' AS name, 'Display trigger information' AS description, '@trig [<owner>.]<trigger_name>'||&nl||'@trig sys.delete_entries'||&nl||'@trig sys.%' AS usage FROM dual UNION ALL
  SELECT 'ts.sql' AS name, 'Display tablespaces' AS description, '@ts <tablespace_name>'||&nl||'@ts soe'||&nl||'@ts %' AS usage FROM dual UNION ALL
  SELECT 'uds.sql' AS name, 'Display undo statistics' AS description, '@uds' AS usage FROM dual UNION ALL
  SELECT 'wrka.sql' AS name, 'Display PGA and TEMP usage' AS description, '@wrka <fileter_expression>'||&nl||'@wrka 1=1'||&nl||'@wrka sid=1000' AS usage FROM dual UNION ALL
  SELECT 'wrkasum.sql' AS name, 'Display summary of SQL workareas groupbed by opertion type (PGA and TEMP)' AS description, '@wrkasum <filter_expression>'||&nl||'@wrkasum sql_id=''7q729nhdgtsqq''' AS usage FROM dual UNION ALL
  SELECT 'x.sql' AS name, 'Display SQL execution plan for the last SQL statement' AS description, '@x' AS usage FROM dual UNION ALL
  SELECT 'xa.sql' AS name, 'Display SQL execution plan for the last SQL statement - alias' AS description, '@xa' AS usage FROM dual UNION ALL
  SELECT 'xall.sql' AS name, 'Display SQL execution plan for the last SQL statement - advanced' AS description, '@xall' AS usage FROM dual UNION ALL
  SELECT 'xawr.sql' AS name, 'Display SQL execution plan from AWR' AS description, '@xawr <sql_id> <plan_hash_value>'||&nl||'@xawr 0sh0fn7r21020 1541789278'||&nl||'@xawr 0sh0fn7r21020 %' AS usage FROM dual UNION ALL
  SELECT 'xb.sql' AS name, 'Explain a SQL statements execution plan with execution profile directly from library cache - for the last SQL executed in current session' AS description, '@xb' AS usage FROM dual UNION ALL
  SELECT 'xbi.sql' AS name, 'Explain a SQL statements execution plan with execution profile directly from library cache - look up by SQL ID' AS description, '@xbi <sql_id> <sql_child_number>'||&nl||'@xbi a5ks9fhw2v9s1 0' AS usage FROM dual UNION ALL
  SELECT 'xi.sql' AS name, 'Display SQL execution plan from library cache' AS description, '@xi <sql_id> <child#>'||&nl||'@xi 7q729nhdgtsqq 0'||&nl||'@xi 7q729nhdgtsqq %' AS usage FROM dual UNION ALL
  SELECT 'xia.sql' AS name, 'Display SQL execution plan from library cache: ADVANCED' AS description, '@xia <sql_id>'||&nl||'@xia 7q729nhdgtsqq' AS usage FROM dual UNION ALL
  SELECT 'xp.sql' AS name, 'Run DBMS_SQLTUNE.REPORT_SQL_MONITOR (text mode) for session' AS description, '@xp <session_id>'||&nl||'@xp 47' AS usage FROM dual UNION ALL
  SELECT 'xprof.sql' AS name, 'Run DBMS_SQLTUNE.REPORT_SQL_MONITOR for session' AS description, '@xprof <report_level> <type> <sql_id|session_id> <sql_id|sid>' AS usage FROM dual UNION ALL
  SELECT 'xplto.sql' AS name, 'Display execution plan operations' AS description, '@xplto <name>'||&nl||'@xplto full' AS usage FROM dual UNION ALL
  SELECT '' AS name, '' AS description, '' AS usage FROM dual UNION ALL
  SELECT '' AS name, '' AS description, '' AS usage FROM dual
  ) 
)
SELECT * FROM q
WHERE
   (upper(name)        LIKE upper ('%&search_string%') OR regexp_like(name, '&search_string', 'i'))
OR (upper(description) LIKE upper ('%&search_string%') OR regexp_like(description, '&search_string', 'i'))
-- OR (upper(usage)       LIKE upper ('%&search_string%') OR regexp_like(usage, '&search_string', 'i'))
ORDER BY
    name
/

UNDEFINE search_string
CLEAR COLUMNS
