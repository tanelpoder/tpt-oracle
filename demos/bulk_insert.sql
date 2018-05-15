-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Simple Export

drop table t;
create table t as select * from all_users where 1=0;

-- this type def is created based on data dictionary definition of extracted table when exporting 
create or replace type rtype as object ( username varchar2(30), user_id number, created date )
/
create or replace type ttype as table of rtype;
/

-- set nls_date format to some standard format

declare
    rows ttype := ttype();
begin 
    insert into t 
    select * from table ( 
        ttype ( 
            rtype('a',1,sysdate), 
            rtype('b',2,sysdate),
            rtype('c',3,sysdate),
            rtype('d',4,sysdate),
            rtype('e',5,sysdate),
            rtype('f',6,sysdate),
            rtype('g',7,sysdate),
            rtype('h',8,sysdate),
            rtype('i',9,sysdate),
            rtype('j',10,sysdate),
            rtype('k',11,sysdate),
            rtype('l',12,sysdate),
            rtype('m',13,sysdate),
            rtype('n',14,sysdate)
        )
    );
end;
/

select * from t;

drop type ttype;
drop type rtype;

-- can we do completely without creating stored types?