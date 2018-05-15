-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column fva_ksmfsnam heading SGAVARNAME for a20
column fva_ksmfstyp heading DATATYPE for a20
column fva_ksmmval_dec heading KSMMVAL_DEC for 99999999999999999999

select /*+ LEADING(f) USE_NL(m) USE_CONCAT */
    f.addr, 
    f.indx, 
    f.ksmfsnam fva_ksmfsnam, 
    f.ksmfstyp fva_ksmfstyp, 
    f.ksmfsadr, 
    f.ksmfssiz, 
    m.ksmmmval,
    to_number(m.ksmmmval, 'XXXXXXXXXXXXXXXX') fva_ksmmval_dec
from 
    x$ksmfsv f, 
    x$ksmmem m
where 
    f.ksmfsadr = m.addr
and (
        f.ksmfsadr = hextoraw( lpad(substr(upper('&1'), instr(upper('&1'), 'X')+1), vsize(f.addr)*2, '0') ) 
        or 
        m.ksmmmval = hextoraw( lpad(substr(upper('&1'), instr(upper('&1'), 'X')+1), vsize(f.addr)*2, '0') )
    )
order by
    ksmfsnam
/

