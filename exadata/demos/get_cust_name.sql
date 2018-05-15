-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

CREATE OR REPLACE FUNCTION get_cust_name (id IN NUMBER) RETURN VARCHAR2 
    AUTHID CURRENT_USER
AS
    n VARCHAR2(1000); 
BEGIN 
    SELECT /*+ FULL(c) */ cust_first_name||' '||cust_last_name INTO n 
    FROM soe.customers c
    WHERE customer_id = id; 
    RETURN n; 
END;
/

