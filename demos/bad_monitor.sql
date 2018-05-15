-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

PROMPT THIS SCRIPT WILL CAUSE A LOT OF TORUBLE!!!
PROMPT DON'T RUN IT IN PRODUCTION!!!
PAUSE PRESS ENTER TO CONTINUE OR CTRL+C TO EXIT...

DECLARE
  j number;
BEGIN
  WHILE true LOOP
    select count(*) into j from x$ksmsp;
  END LOOP;
END;
/

