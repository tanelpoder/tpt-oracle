-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- view merging

select * from dual;

select * from table(dbms_xplan.display_cursor);

create or replace view v as select * from dual;

select * from (select * from v);

alter session set "_simple_view_merging"=false;

select * from (select * from v);

alter session set "_simple_view_merging"=true;

select * from (select /*+ NO_MERGE */ * from v);

select * from (select rownum r, v.* from v);


-- scalar subqueries, run a subquery for populating a value in a single column or a row (9i+)

select owner, count(*) from test_objects o group by owner;

-- another way (excludes nulls if any)

select u.username, (select count(*) from test_objects o where u.username = o.owner) obj_count from test_users u;

select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));


