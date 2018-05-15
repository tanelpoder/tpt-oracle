-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Dropping and creating users...

drop user a cascade;
drop user aa cascade;

set echo on

create user A identified by x;
create user AA identified by x;
alter user a quota unlimited on users;
alter user aa quota unlimited on users;

-- about to create two tables under different usernames...
pause

create table A.AA(a int);
create table AA.A(a int);

-- about to run @aot/hash <object_name> commands for both tables...
pause

set echo off

@aot/hash a
@aot/hash aa

