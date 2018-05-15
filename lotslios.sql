-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   lotslios.sql
-- Purpose:     Generate Lots of Logical IOs for testing purposes
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--
-- Usage:       @lotslios <number>
--              @lotslios 100
--              @lotslios 1000000
--
-- Other:       As the script self-joins SYS.OBJ$ to itself the maximum number
--              of rows processed (and LIOs generated) depends on the number
--              of rows in SYS.OBJ$
--
--------------------------------------------------------------------------------

prompt generate lots of LIOs by repeatedly full scanning through a small table...

select
    /*+ monitor
        ordered 
        use_nl(b) use_nl(c) use_nl(d) 
        full(a) full(b) full(c) full(d) */
    count(*)
from
    sys.obj$ a,
    sys.obj$ b,
    sys.obj$ c,
    sys.obj$ d
where
    a.owner# = b.owner#
and b.owner# = c.owner#
and c.owner# = d.owner#
and rownum <= &1
/
