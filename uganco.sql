-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Note that this script shows you only the dblinks opened in your own session, not others!
-- the v$dblink view uses the same x$ and has the same limitation...

COL uganco_protocol FOR A5 HEAD PROTO

SELECT
    addr
  , ncouid conn_owner
  , ncouct refcount
  , decode(bitand(ncoflg, 2), 0, 'NO', 'YES') in_trans
  , decode(bitand(ncoflg, 8), 0, 'NO', 'YES') update_sent
  , decode(hstpro, 1, 'V5', 2, 'V6', 3, 'V6_NLS', 4, 'V7', 5, 'V8', 6, 'V8.1', '#'||hstpro) uganco_protocol
  , nconam global_name
FROM
    x$uganco
/

