-- Copyright 2023 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- awr_sqlid_binds.sql v0.1

COL binds_begin_time FOR A25
COL binds_instance_number HEAD INST FOR 9999
COL binds_name HEAD NAME FOR A15
COL binds_value_string HEAD VALUE_STRING FOR A100 WRAP
COL binds_position HEAD POS FOR 9999
COL binds_dup_position HEAD DPOS FOR 9999

SELECT
    sn.begin_interval_time binds_begin_time
  , sn.dbid
  , sn.instance_number     binds_instance_number
  , sb.sql_id
  , sb.name                binds_name
  , sb.position            binds_position
  , sb.dup_position        binds_dup_position
  , sb.datatype_string
--  , sb.character_sid
--  , sb.precision
--  , sb.scale
  , sb.was_captured
  , sb.last_captured
  , sb.value_string        binds_value_string
FROM
    dba_hist_snapshot sn
  , dba_hist_sqlbind  sb
WHERE
    sn.snap_id = sb.snap_id
AND sn.dbid    = sb.dbid
AND sn.instance_number = sb.instance_number
AND sb.sql_id = '&1'
AND &2
AND begin_interval_time >= &3
AND end_interval_time   <= &4
ORDER BY
    sn.begin_interval_time
  , sn.dbid
  , sn.instance_number
  , sb.sql_id
  , sb.name
  , sb.position
/

