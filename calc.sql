-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   calc.sql
-- Purpose:     Basic calculator and dec/hex converter
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @calc <num1> <operation> <num2>
-- 	        	@calc 10 + 10
--	        	@calc 10 + 0x10
--				@calc 0xFFFF - 0x5F
--				@calc xBB * 1234
-- Other:       
--				Can calculate only 2 operands a time
--              You can use just "x" instead of "0x" for indicating hex numbers
--
--------------------------------------------------------------------------------

COL calc_dec HEAD "DEC" FOR 999999999999999999999999999.999999
COL calc_hex HEAD "HEX" FOR A20 JUSTIFY RIGHT


with 
p1 as (
    select case 
             when lower('&1') like '%x%' then 'XXXXXXXXXXXXXXXXXX' 
             else '999999999999999999999999999.9999999999' 
             end
           format 
    from dual
),
p3 as (
    select case 
             when lower('&3') like '%x%' then 'XXXXXXXXXXXXXXXXXX' 
             else '999999999999999999999999999.9999999999' 
             end
           format 
    from dual
)
select 
    -- decimal
    to_number(substr('&1',instr(upper('&1'),'X')+1), p1.format) 
      &2 
    to_number(substr('&3',instr(upper('&3'),'X')+1), p3.format) calc_dec,
    -- hex
    to_char( to_number(substr('&1',instr(upper('&1'),'X')+1), p1.format)
               &2 
             to_number(substr('&3',instr(upper('&3'),'X')+1), p3.format)
    , 'XXXXXXXXXXXXXXXXXXX') calc_hex
from 
    p1,p3
/
