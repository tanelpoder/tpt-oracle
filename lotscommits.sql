-- You need this table:
-- CREATE TABLE lotscommits TABLESPACE users AS SELECT 1 a FROM dual;

PROMPT This script will issue lots of synchronous commits and will generate undo/redo
PROMPT It will require a "lotscommits" table (see the header of this script)
PROMPT
PROMPT PROMPT Press ENTER start or CTRL+C to cancel...
PAUSE 
PROMPT Running...

BEGIN
  LOOP
    UPDATE lotscommits SET a = a + 1;
    COMMIT WRITE WAIT IMMEDIATE;
  END LOOP;
END;
/

