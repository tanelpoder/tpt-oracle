-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column fvar_ksmfsnam heading SGAVARNAME for a30
column fvar_ksmfstyp heading DATATYPE for a30
column fval_ksmmval_dec heading VALUE_DEC for 999999999999990

select /*+ ORDERED USE_NL(m) NO_EXPAND */
    f.addr
  , f.indx
  , f.ksmfsnam fvar_ksmfsnam
  , f.ksmfstyp fvar_ksmfstyp
  , f.ksmfsadr
  , f.ksmfssiz
  , m.ksmmmval
  , to_number(rawtohex(m.ksmmmval), 'XXXXXXXXXXXXXXXX') fval_ksmmval_dec
/*  ,  (select ksmmmval from x$ksmmem where addr = hextoraw(
                                                    to_char(
                                                        to_number(
                                                            rawtohex(f.ksmfsadr),
                                                            'XXXXXXXX'
                                                        ) + 0,
                                                    'XXXXXXXX')
                                                ) 
    ) ksmmmval2 */
from
    x$ksmfsv f
  , x$ksmmem m
where
    f.ksmfsadr = m.addr
and (rawtohex(m.ksmmmval) like upper('&1'))
order by
    ksmfsnam
/
