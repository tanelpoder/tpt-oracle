-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show undo statistics from V$UNDOSTAT....
col uds_mb head MB format 999999.99
col uds_maxquerylen head "MAX|QRYLEN" format 999999
col uds_maxqueryid  head "MAX|QRY_ID" format a13 
col uds_ssolderrcnt head "ORA-|1555" format 999
col uds_nospaceerrcnt head "SPC|ERR" format 99999
col uds_unxpstealcnt head "UNEXP|STEAL" format 99999
col uds_expstealcnt head "EXP|STEAL" format 99999

select * from (
    select 
        begin_time, 
        to_char(end_time, 'HH24:MI:SS') end_time, 
        txncount, 
        undoblks * (select block_size from dba_tablespaces where upper(tablespace_name) = 
                        (select upper(value) from v$parameter where name = 'undo_tablespace')
                   ) / 1048576 uds_MB ,
        maxquerylen uds_maxquerylen,
        maxqueryid  uds_maxqueryid,
        ssolderrcnt uds_ssolderrcnt,
        nospaceerrcnt uds_nospaceerrcnt,
 	unxpstealcnt uds_unxpstealcnt,
	expstealcnt uds_expstealcnt
    from 
        v$undostat
    order by
        begin_time desc
) where rownum <= 30;
