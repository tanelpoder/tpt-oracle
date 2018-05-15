-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select al.thread#, al.sequence#, al.first_change#, al.blocks * al.block_size "Size kB", bp.handle backup_piece
from 
    v$backup_redolog al, 
    v$backup_set bs, 
    v$backup_piece bp
where
    al.recid = bs.recid
and bs.recid = bp.recid
and al.stamp = bs.stamp
and bs.stamp = bp.stamp
and al.sequence# between 8000 and 8600;