-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- blcass.sql by Tanel Poder (http://blog.tanelpoder.com)
--
-- Usage: @bclass <block_class#>

--with undostart as (select r from (select rownum r, class from v$waitstat) where class = 'undo header')

select class, r undo_segment_id from (
    select class, null r
    from (select class, rownum r from v$waitstat) 
    where r = bitand(&1,to_number('FFFF','XXXX'))
    union all
    select 
        decode(mod(bitand(&1,to_number('FFFF','XXXX')) - 17,2),0,'undo header',1,'undo data', 'error') type 
      , trunc((bitand(&1,to_number('FFFF','XXXX')) - 17)/2) undoseg_id
    from 
        dual
)
where rownum = 1
/
