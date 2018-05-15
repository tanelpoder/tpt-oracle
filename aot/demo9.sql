-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


drop table a;
drop table b;

create table A(col11 number, col12 number);
create table B(col21 number, col22 number);

insert into a values (-3,-7);
insert into a values (null,-1);
insert into b values ( -7,-3);

update a set col11 =
    (select avg(b.col22) keep (dense_rank first order by (col22)) 
     FROM b where b.col21= a.col12)
/

