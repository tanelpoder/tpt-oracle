-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Original by William Robertson but modified by Tanel - added the varying array filter
-- in comment section: http://awads.net/wp/2005/10/13/pre-defined-collection-types-in-oracle/

SELECT ct.owner, ct.type_name, ct.elem_type_name, ct.length
FROM   all_coll_types ct
     , all_types ot
WHERE  ct.coll_type IN ('TABLE', 'VARYING ARRAY')
AND    ot.type_name(+) = ct.elem_type_name
AND    ot.owner(+) = ct.elem_type_owner
AND    ot.type_name IS NULL
ORDER BY ct.owner, ct.type_name
/

