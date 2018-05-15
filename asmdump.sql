-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- simple asm dump utility
-- use full database file name (with +datagroup name) as only parameter
-- nb! doesnt work properly on multidisk diskgroups with fine grained striping
-- single disk disk groups with fine grained striping or multidisk groups
-- with coarse grained striping are ok
--
-- tanel poder - nov 2005 [ http://www.tanelpoder.com ]

set lines 300 trim on verify off pages 50000

select
    'dd if='|| d.path||' bs=1048576 skip='||AU_KFFXP||' count=1 '||
    '>> /tmp/'||substr('&1',instr('&1','/',-1)+1)||'.dmp'  cmd
from
    X$KFFXP X, V$ASM_DISK D, V$ASM_ALIAS A
where
    lower(A.NAME) = lower(substr('&1',instr('&1','/',-1)+1))
    and X.NUMBER_KFFXP = A.FILE_NUMBER
    and X.GROUP_KFFXP  = A.GROUP_NUMBER
    and X.INCARN_KFFXP = A.FILE_INCARNATION
    and X.DISK_KFFXP = D.DISK_NUMBER
    and X.GROUP_KFFXP = D.GROUP_NUMBER
order by
    X.XNUM_KFFXP;

