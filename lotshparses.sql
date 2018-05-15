-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   lotshparses.sql
-- Purpose:     Generate Lots of hard parses and shared pool activity 
--              for testing purposes
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @lotshparses <number>
--              @lotshparses 100
--              @lotshparses 1000000
--	        
-- Other:       You probably don't want to run this in production as it can
--              fill your shared pool with junk and flush out any useful stuff!
--
--------------------------------------------------------------------------------

-- ALTER SESSION SET optimizer_adaptive_features=false;

declare
    x number;
begin
    for i in 1..&1 loop
    	execute immediate 'select count(*) from dual where rownum = '||to_char(dbms_random.random) into x;
    end loop;
end;
/
