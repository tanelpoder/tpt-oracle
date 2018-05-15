-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

begin
	begin
		sys.dbms_logmnr.end_logmnr;
	exception
		when others then null;
	end;

	sys.dbms_logmnr.add_logfile('&1');
	sys.dbms_logmnr.start_logmnr ( options => dbms_logmnr.dict_from_online_catalog );
end;
/

