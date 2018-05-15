-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- GRANT EXECUTE ON sys.dbms_advanced_rewrite TO &user 
-- there's no public synonym for this package so you should reference it by schema name

exec sys.DBMS_ADVANCED_REWRITE.DROP_REWRITE_EQUIVALENCE ('test_rewrite');

begin
   sys.DBMS_ADVANCED_REWRITE.DECLARE_REWRITE_EQUIVALENCE (
      'test_rewrite'
    , 'select username,created from test_users u where username in (select owner from test_objects o where o.owner = u.username)'
    , 'select /*+ qb_name(main) no_unnest(@subq) */ username,created from test_users u where username in (select /*+ qb_name(subq) */ owner from test_objects o where o.owner = u.username) and /* careful! */ 1=1'
    , validate => true
    , rewrite_mode => 'general'
   );
end;
/


alter session set query_rewrite_enabled = true -- this is true by default;
alter session set query_rewrite_integrity = trusted;

-- if you see a FILTER operation (not a HASH JOIN SEMI) then the rewrite worked
select username,created from test_users u where username in (select owner from test_objects o where o.owner = u.username);
@x9a


-- an example of how to add a missing ORDER BY to a statement which assumes that GROUP BY always orders data too
-- (this is not true in 10.2+ where GROUP BY and DISTINCT operations can be done using hashing instead of sorting)

exec sys.DBMS_ADVANCED_REWRITE.DROP_REWRITE_EQUIVALENCE ('test_rewrite_order');

begin
   sys.DBMS_ADVANCED_REWRITE.DECLARE_REWRITE_EQUIVALENCE (
      'test_rewrite_order'
    , 'select owner,count(*) from test_objects group by owner'
    , 'select * from (select owner,count(*) from test_objects group by owner order by owner)'
    , validate => true
    , rewrite_mode => 'text_match'
   );
end;
/

select owner,count(*) from test_objects group by owner;
@x9a


