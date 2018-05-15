-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col ii_service_name	head SERVICE_NAME 	for a20
col ii_module 		head MODULE		for a32
col ii_action		head ACTION		for a32
col ii_client_identifier head CLIENT_IDENTIFIER	for a32
col ii_client_info	head CLIENT_INFO	for a32
col ii_program head PROGRAM for a20 truncate

select 
        userenv('SID') sid , 
        userenv('SESSIONID') audsid, 
        '0x'||trim(to_char(userenv('SID'), 'XXXX')) "0xSID",
        '0x'||trim(to_char(userenv('SESSIONID'), 'XXXXXXXX')) "0xAUDSID", 
        program     ii_program,
	module			ii_module, 
	action			ii_action, 
	service_name		ii_service_name, 
	client_identifier	ii_client_identifier, 
	client_info 		ii_client_info
from 
--	v$session where audsid = sys_context('USERENV', 'SESSIONID')
	v$session where sid = sys_context('USERENV', 'SID')
/
