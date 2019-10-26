-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select
--      sql_id
--    , child_number
--    , plan_hash_value
     substr(extractvalue(value(d), '/hint'), 1, 100) as outline_hints
from
      xmltable('/*/outline_data/hint'
        passing (
           select
            xmltype(other_xml) as xmlval
           from
            v$sql_plan
           where
            sql_id = '&1'
           and  child_number like '&2' 
           and  other_xml is not null
        )
) d
/

--select regexp_substr(other_xml,'<!\[CDATA\[.*?\]\]>') from v$sql_plan where sql_id = '&1' and child_number like '&2';

-- SELECT /*+ opt_param('parallel_execution_enabled', 'false') */
--    SUBSTR(EXTRACTVALUE(VALUE(d), '/hint'), 1, 4000) hint
-- FROM
--     v$sql_plan p
--   , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(p.other_xml), '/*/outline_data/hint'))) d
-- where 
--     sql_id = '&1' 
-- and child_number like '&2'
-- /

