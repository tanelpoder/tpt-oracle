-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show global transactions from X$K2GTE2...
prompt You can find the remote endpoint's process and session via remote_spid

COL gtrans_global_tid HEAD GLOBAL_TRANSACTION_ID FOR A45
COL gtrans_local_sid_serial HEAD LOCAL_SID FOR A15
COL gtrans_remote_spid HEAD REMOTE_SPID FOR A11
COL gtrans_remote_machine HEAD REMOTE_MACHINE FOR A30

select /*+ leading(gt) */
    gt.k2gtitid_ora           gtrans_global_tid
  , s.username
  , s.sid||','||s.serial#     gtrans_local_sid_serial
  , s.machine                 gtrans_remote_machine
  , s.process                 gtrans_remote_spid
  , decode (K2GTDFLG, 0, 'ACTIVE', 1,
                          'COLLECTING', 2, 'FINALIZED',
                          4, 'FAILED', 8, 'RECOVERING', 16, 'UNASSOCIATED',
                          32, 'FORGOTTEN', 64, 'READY FOR RECOVERY',
                          128, 'NO-READONLY FAILED', 256, 'SIBLING INFO WRITTEN',
                          512,      '[ORACLE COORDINATED]ACTIVE',
                          512+1,    '[ORACLE COORDINATED]COLLECTING',
                          512+2,    '[ORACLE COORDINATED]FINALIZED',
                          512+4,    '[ORACLE COORDINATED]FAILED',
                          512+8,    '[ORACLE COORDINATED]RECOVERING',
                          512+16,   '[ORACLE COORDINATED]UNASSOCIATED',
                          512+32,   '[ORACLE COORDINATED]FORGOTTEN',
                          512+64,   '[ORACLE COORDINATED]READY FOR RECOVERY',
                          512+128,  '[ORACLE COORDINATED]NO-READONLY FAILED',
                          1024,     '[MULTINODE]ACTIVE',
                          1024+1,   '[MULTINODE]COLLECTING',
                          1024+2,   '[MULTINODE]FINALIZED',
                          1024+4,   '[MULTINODE]FAILED',
                          1024+8,   '[MULTINODE]RECOVERING',
                          1024+16,  '[MULTINODE]UNASSOCIATED',
                          1024+32,  '[MULTINODE]FORGOTTEN',
                          1024+64,  '[MULTINODE]READY FOR RECOVERY',
                          1024+128, '[MULTINODE]NO-READONLY FAILED',
                          1024+256, '[MULTINODE]SIBLING INFO WRITTEN',
                          'COMBINATION') status
  , K2GTDFLG
  , decode (K2GTETYP, 0, 'FREE', 1, 'LOOSELY COUPLED', 2, 'TIGHTLY COUPLED') coupling
from
     x$k2gte2 gt
   , v$session s
where
    gt.k2gtdses = s.saddr
/

