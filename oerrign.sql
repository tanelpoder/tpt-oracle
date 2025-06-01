COL oerr_command_name HEAD SQL_COMMAND_NAME FOR A35
COL oerr_error_text HEAD ERROR_TEXT FOR A80 WORD_WRAP

WITH
    FUNCTION errtext(oerr IN NUMBER)
    RETURN VARCHAR2 IS
    BEGIN
        RETURN SQLERRM(-oerr);
    END;
SELECT
    c.command_type cmd
  , c.command_name oerr_command_name
  , e.error_number oraerr
  , errtext(e.error_number) oerr_error_text
FROM
    v$app_ignorable_errors e
  , v$sqlcommand c 
WHERE 
    e.command_type = c.command_type 
ORDER BY 
    cmd
  , error_number
/

