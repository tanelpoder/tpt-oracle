-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   curheaps.sql
-- Purpose:     Show main cursor data block heap sizes and their contents
--              (heap0 and heap6)
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @curheaps <hash_value> <child#>
--
--              @curheaps 942515969 %   -- shows a summary of cursor heaps
--	            @curheaps 942515969 0   -- shows detail for child cursor 0
--
-- Other:       "Child" cursor# 65535 is actually the parent cursor
--
--------------------------------------------------------------------------------

col curheaps_size0 heading SIZE0 for 9999999
col curheaps_size1 heading SIZE1 for 9999999
col curheaps_size2 heading SIZE2 for 9999999
col curheaps_size3 heading SIZE3 for 9999999
col curheaps_size4 heading SIZE4 for 9999999
col curheaps_size5 heading SIZE5 for 9999999
col curheaps_size6 heading SIZE6 for 9999999
col curheaps_size7 heading SIZE7 for 9999999

col KGLOBHD0 new_value v_curheaps_kglobhd0 print
col KGLOBHD1 new_value v_curheaps_kglobhd1 noprint
col KGLOBHD2 new_value v_curheaps_kglobhd2 noprint
col KGLOBHD3 new_value v_curheaps_kglobhd3 noprint
col KGLOBHD4 new_value v_curheaps_kglobhd4 print
col KGLOBHD5 new_value v_curheaps_kglobhd5 noprint
col KGLOBHD6 new_value v_curheaps_kglobhd6 print
col KGLOBHD7 new_value v_curheaps_kglobhd7 noprint


select 
	KGLNAHSH,
	KGLHDPAR,
	kglobt09 CHILD#,
	KGLHDADR,
	KGLOBHD0, KGLOBHS0 curheaps_size0,
	KGLOBHD1, KGLOBHS1 curheaps_size1,
	KGLOBHD2, KGLOBHS2 curheaps_size2,
	KGLOBHD3, KGLOBHS3 curheaps_size3,
	KGLOBHD4, KGLOBHS4 curheaps_size4,
	KGLOBHD5, KGLOBHS5 curheaps_size5,
	KGLOBHD6, KGLOBHS6 curheaps_size6,
	KGLOBHD7, KGLOBHS7 curheaps_size7,
--	KGLOBT00 CTXSTAT,
	KGLOBSTA STATUS
from 
	X$KGLOB
--	X$KGLCURSOR_CHILD
where
	KGLNAHSH in (&1)
and	KGLOBT09 like ('&2')
order by
        KGLOBT09 ASC
/

-- Cursor data block summary
select 
   'HEAP0'        heap
  , ksmchcls      class
  , ksmchcom      alloc_comment
  , sum(ksmchsiz) bytes
  , count(*)      chunks
from 
    x$ksmhp
where 
    KSMCHDS = hextoraw('&v_curheaps_kglobhd0')
group by
   'HEAP0'
  , ksmchcls
  , ksmchcom
order by
    sum(ksmchsiz) desc
/

select 
   'HEAP4'        heap
  , ksmchcls      class
  , ksmchcom      alloc_comment
  , sum(ksmchsiz) bytes
  , count(*)      chunks
from 
    x$ksmhp
where 
    KSMCHDS = hextoraw('&v_curheaps_kglobhd4')
group by
   'HEAP4'
  , ksmchcls
  , ksmchcom
order by
    sum(ksmchsiz) desc
/



select 
   'HEAP6'        heap
  , ksmchcls      class
  , ksmchcom      alloc_comment
  , sum(ksmchsiz) bytes
  , count(*)      chunks
from 
    x$ksmhp
where 
    KSMCHDS = hextoraw('&v_curheaps_kglobhd6')
group by
   'HEAP6'
  , ksmchcls
  , ksmchcom
order by
    sum(ksmchsiz) desc
/


-- Cursor data block details

-- select * from x$ksmhp where KSMCHDS = hextoraw('&v_curheaps_kglobhd0');
-- select * from x$ksmhp where KSMCHDS = hextoraw('&v_curheaps_kglobhd6');

