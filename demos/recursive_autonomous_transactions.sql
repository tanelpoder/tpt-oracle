-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

declare
    procedure p is
        pragma autonomous_transaction;
    begin
	begin
              insert into t values(1);
--              set transaction read only;
              dbms_lock.sleep(1);
--        exception
--            when others then null;
        end;
	p;
    end;

begin
    p;
end;
/
