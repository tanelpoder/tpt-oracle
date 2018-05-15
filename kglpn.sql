-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--
-- kglpn.sql by Tanel Poder (http://blog.tanelpoder.com)
--

col kglpn_object_name head OBJECT_NAME for a40
col kglpn_pinned_blocks head PINNED_BLOCKS for a13 word_wrap

-- there's a reason for the use_hash hint, we don't want to hammer libcache with a lot of single object lookups
-- which a nested loops join would cause if lots of objects are returned from x$kglpn (for a handful of rows
-- a nested loop would be better, but hash join is safer with large amount of rows in this case)

select * from (
    select /*+ merge leading(p,g) use_hash(g) */ 
        kglhdadr
    --  , kglpnuse
    --  , kglpnses
      , s.sid
      , s.username
      , g.kglnahsh              kglnahsh
      , g.kglnahsh              hash_value
      , kglpncnt                refcnt
      , SUBSTR(CASE kglpnmod WHEN 0 THEN 'None' WHEN 2 THEN 'Share' WHEN 3 THEN 'Excl' ELSE TO_CHAR(kglpnmod) END, 1,5) pin_mode
      , SUBSTR(CASE kglpnreq WHEN 0 THEN 'None' WHEN 2 THEN 'Share' WHEN 3 THEN 'Excl' ELSE TO_CHAR(kglpnreq) END, 1,5) req_mode
      ,  CASE WHEN BITAND(kglpndmk,       1)=    1  THEN '0 '   END
      || CASE WHEN BITAND(kglpndmk,       2)=    2  THEN '1 '   END 
      || CASE WHEN BITAND(kglpndmk,       4)=    4  THEN '2 '   END
      || CASE WHEN BITAND(kglpndmk,       8)=    8  THEN '3 '   END
      || CASE WHEN BITAND(kglpndmk,      16)=   16  THEN '4 '   END
      || CASE WHEN BITAND(kglpndmk,      32)=   32  THEN '5 '   END
      || CASE WHEN BITAND(kglpndmk,      64)=   64  THEN '6 '   END
      || CASE WHEN BITAND(kglpndmk,     128)=  128  THEN '7 '   END
      || CASE WHEN BITAND(kglpndmk,     256)=  256  THEN '8 '   END
      || CASE WHEN BITAND(kglpndmk,     512)=  512  THEN '9 '   END
      || CASE WHEN BITAND(kglpndmk,    1024)= 1024  THEN '10 '  END
      || CASE WHEN BITAND(kglpndmk,    2048)= 2048  THEN '11 '  END
      || CASE WHEN BITAND(kglpndmk,    4096)= 4096  THEN '12 '  END
      || CASE WHEN BITAND(kglpndmk,    8192)= 8192  THEN '13 '  END
      || CASE WHEN BITAND(kglpndmk,   16384)=16384  THEN '14 '  END
      || CASE WHEN BITAND(kglpndmk,   32768)=32768  THEN '15'   END kglpn_pinned_blocks
      , nvl2(kglnaown, kglnaown||'.', null)||kglnaobj kglpn_object_name
    from 
        x$kglpn p, 
        x$kglob g,
        v$session s
    where 
        p.kglpnhdl = g.kglhdadr
    and p.kglpnuse = s.saddr (+)
)
where &1
/

