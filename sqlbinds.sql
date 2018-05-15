-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show captured binds from V$SQL_BIND_CAPTURE...

SELECT
  ADDRESS         parent_cursor
, SQL_ID              
, CHILD_NUMBER        
, NAME            sqlbinds_name              
, POSITION            
, DUP_POSITION        
, DATATYPE            
, DATATYPE_STRING     
, CHARACTER_SID       
, PRECISION           
, SCALE               
, MAX_LENGTH          
, WAS_CAPTURED        
, LAST_CAPTURED       
, VALUE_STRING        
, VALUE_ANYDATA  
FROM
  v$sql_bind_capture
WHERE
    sql_id like '&1'
AND child_number like '&2'
ORDER BY
     address
  ,  sql_id
  , child_number
/
