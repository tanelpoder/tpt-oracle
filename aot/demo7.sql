-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- from metalink bug 2456257

-- drop table fact;

create table fact (
id number primary key,
col01 number, col02 number, col03 number, col04 number,
col05 number, col06 number, col07 number, col08 number,
col09 number, col10 number, col11 number, col12 number,
col13 number, col14 number, col15 number, col16 number,
col17 number, col18 number, col19 number, col20 number,
dat01 number, dat02 number, dat03 number, dat04 number,
dat05 number, dat06 number, dat07 number, dat08 number,
dat09 number, dat10 number
); 


select
id,
col01, col02, col03, col04, col05, col06, col07, col08, col09, col10,
col11, col12, col13, col14, col15, col16, col17, col18, col19, col20,
sum(dat01), sum(dat02), sum(dat03), sum(dat04), sum(dat05),
sum(dat06), sum(dat07), sum(dat08), sum(dat09), sum(dat10)
from
fact
group by cube ( id,
col01, col02, col03, col04, col05, col06, col07, col08, col09, col10,
col11, col12, col13, col14, col15, col16, col17, col18, col19, col20
);

