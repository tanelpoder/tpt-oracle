-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
--
-- Explain AutoTask names such as: ORA$AT_OS_OPT_SY_6809

COL task_class      FOR A40
COL task_operation  FOR A40
COL task_type       FOR A40

SELECT
    (SELECT cname_ketcl  FROM x$ketcl WHERE ctag_ketcl = REGEXP_SUBSTR('&1', '([[:alnum:]]+)', 1, 3)) task_class
  , (SELECT opname_ketop FROM x$ketop WHERE otag_ketop = REGEXP_SUBSTR('&1', '([[:alnum:]]+)', 1, 4)) task_operation
  , (SELECT tname_kettg  FROM x$kettg WHERE ttag_kettg = REGEXP_SUBSTR('&1', '([[:alnum:]]+)', 1, 5)) task_type
FROM dual
/
