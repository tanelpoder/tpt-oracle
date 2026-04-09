-- Convert (owner,table,partition_name) tuple into a VARCHAR2 string
-- Due to the limitations of Oracle's LONG datatype handling, this
-- is done via a SQL query in the PL/SQL function that is then called
-- by your custom data dictionary queries.
--
-- Normally this is not good practice for performance, but it helps 
-- work around Oracle's limitations with LONG datatype handling and
-- such partition metadata queries normally do not return many rows.
--
-- More info:
--   https://tanelpoder.com/posts/oracle-get-partition-high-value-function
--

CREATE OR REPLACE FUNCTION get_partition_high_value(
        p_owner IN VARCHAR2
      , p_table_name IN VARCHAR2
      , p_partition_name IN VARCHAR2
    )
    RETURN VARCHAR2
    AUTHID CURRENT_USER
AS
    lv_long    LONG;
BEGIN
    SELECT high_value INTO lv_long
    FROM all_tab_partitions
    WHERE
        table_owner    = p_owner
    AND table_name     = p_table_name
    AND partition_name = p_partition_name;

    RETURN TO_CHAR(lv_long);
END;
/

