-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- CREATE OR REPLACE FUNCTION HEXSTR ( p_number in number ) return varchar2
-- as
--         l_str varchar2(4000) := to_char(p_number,'fm'||rpad('x',50,'x'));
--         l_return varchar2(4000);
-- begin
--         while ( l_str is not null )
--         loop
--                 l_return := l_return || chr(to_number(substr(l_str,1,2),'xx'));
--                 l_str := substr( l_str, 3 );
--         end loop;
--         return l_return;
-- end;
-- /
-- 
-- GRANT EXECUTE ON HEXSTR TO PUBLIC;
-- CREATE OR REPLACE PUBLIC SYNONYM HEXSTR FOR HEXSTR;

col tabhist_ep_actual_value head ENDPOINT_ACTUAL_VALUE for a40
col tabhist_ep_value        head ENDPOINT_VALUE for a30 just right
col tabhist_ep_value2       for a80
col tabhist_col_name        head COLUMN_NAME for a30
col tabhist_data_type       head DATA_TYPE for a20 word_wrap

break on tabhist_col_name on tabhist_data_type skip 1

select
    h.column_name                  tabhist_col_name
  , c.data_type                    tabhist_data_type
  , h.endpoint_number
  , CASE 
        WHEN c.data_type = 'NUMBER' THEN LPAD(TO_CHAR(h.endpoint_value), 30, ' ') 
        WHEN c.data_type IN ('CHAR', 'VARCHAR2', 'NCHAR', 'NVARCHAR2') THEN
             --to_char(to_number((substr(trim(to_char(h.endpoint_value,lpad('x',63,'x'))),1,12)),'XXXXXXXXXXXXXXXX'))
             to_char(to_number((substr(trim(to_char(h.endpoint_value,lpad('x',63,'x'))),1,12)),'XXXXXXXXXXXXXXXX'),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
             --hexstr(to_number((substr(trim(to_char(h.endpoint_value,lpad('x',63,'x'))),1,12)),'XXXXXXXXXXXXXXXX'))
             --hexstr(substr(to_char(h.endpoint_value,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'),1,12))
        ELSE
             trim(substr(trim(to_char(h.endpoint_value,lpad('x',63,'x'))),1,12))
    END tabhist_ep_value
  , CASE WHEN c.histogram = 'FREQUENCY' THEN
        h.endpoint_number - lag(endpoint_number, 1) over ( order by
                                                            h.owner
                                                          , h.table_name
                                                          , h.column_name
                                                          , h.endpoint_number
        ) ELSE NULL 
    END frequency
   ,CASE WHEN c.histogram = 'HEIGHT BALANCED' THEN 
        CASE WHEN c.data_type = 'NUMBER' THEN 
              h.endpoint_value - lag(endpoint_value, 1) over ( order by
                                                            h.owner
                                                          , h.table_name
                                                          , h.column_name
                                                          , h.endpoint_number
        )
        ELSE null END  
    ELSE null END height_bal
--  , hexstr(h.endpoint_value)              tabhist_ep_value
--  , to_char(h.endpoint_value,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')              tabhist_ep_value2
  , h.endpoint_actual_value        tabhist_ep_actual_value
from
    dba_tab_columns     c
  , dba_tab_histograms  h
where
    c.owner         = h.owner
and c.table_name    = h.table_name
and c.column_name   = h.column_name
and upper(h.table_name) LIKE 
                upper(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND h.owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
AND UPPER(h.column_name) LIKE UPPER('&2')
ORDER BY
    h.owner
  , h.table_name
  , h.column_name
  , h.endpoint_number
/
