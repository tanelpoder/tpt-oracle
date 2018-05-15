-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   lotssparses.sql
-- Purpose:     Generate Lots of soft parses and library cache/mutex activity 
--              for testing purposes
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @lotsparses <number>
--              @lotsparses 100
--              @lotsparses 1000000
--	        
-- Other:       You probably don't want to run this in production as it can
--              fill your shared pool with junk and flush out any useful stuff!
--
--------------------------------------------------------------------------------

declare
    x number;
begin
    for i in 1..&1 loop
    	execute immediate 'select count(*) cnt from dual x1 where rownum = 1';
    end loop;
end;
/
