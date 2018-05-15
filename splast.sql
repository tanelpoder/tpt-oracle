-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set termout off

col end_snap new_value   end_snap
col begin_snap new_value begin_snap

with s as (
    select max(snap_id) end_snap from stats$snapshot
)
select end_snap, (select max(snap_id) begin_snap from stats$snapshot where snap_id < s.end_snap) begin_snap 
from s;

def report_name=splast.txt

-- @?/rdbms/admin/spreport
@$HOME/work/oracle/statspack/11.2/spreport

undef end_snap
undef begin_snap

set termout on

host open splast.txt
