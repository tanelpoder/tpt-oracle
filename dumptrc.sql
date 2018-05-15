-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

alter session set tracefile_identifier = &1;
alter session set events 'immediate trace name &1';
alter session set tracefile_identifier = '';
