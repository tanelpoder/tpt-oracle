-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

BEGIN
  LOOP 
    BEGIN 
      EXECUTE IMMEDIATE 'select count(*) from dual where blah = 5'; 
    EXCEPTION 
      WHEN others THEN NULL; 
    END; 
  END LOOP;
END;
/

