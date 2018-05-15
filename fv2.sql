-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column fv_ksmfsnam heading SGAVARNAME for a50 wrap
column fv_ksmfstyp heading DATATYPE for a25 wrap
column fv_ksmmval_dec heading KSMMVAL_DEC for 99999999999999999999

prompt Display Fixed SGA Variables matching &1

select /*+ ORDERED USE_NL(m) */
    f.addr
  , f.indx
  , f.ksmfsnam fv_ksmfsnam
  , to_number(m.ksmmmval, 'XXXXXXXXXXXXXXXX') fv_ksmmval_dec
  , m.ksmmmval
  , f.ksmfstyp fv_ksmfstyp
  , f.ksmfsadr
  , f.ksmfssiz 
from 
    x$ksmfsv f, x$ksmmem m
where 
    f.ksmfsadr = m.addr
and (lower(ksmfsnam) like lower('&1') or lower(ksmfstyp) like lower('&1'))
order by
    ksmfsnam
/



