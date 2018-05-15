-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- LatchProfX collector v2.0 by Tanel Poder (blog.tanelpoder.com)

-- drop table latchprof_reasons;

create table latchprof_reasons (
    indx number not null
  , reason_name varchar2(200) not null
  , reason_label varchar2(200)
  , primary key (indx)
)
organization index
tablespace users
/

insert into latchprof_reasons (indx,reason_name,reason_label)
select indx, ksllwnam, ksllwlbl
from x$ksllw
/

commit;

--drop table latchprof_history;

create table latchprof_history
    tablespace users
as
select 
    systimestamp     sample_timestamp
  , lh.ksuprpid      pid
  , lh.ksuprsid      sid
  , lh.ksuprlat      child_address
  , lh.ksuprlnm      latch_name
  , lh.ksuprlmd      hold_mode
  , lh.ksulawhr      where_location
  , lh.ksulawhy      which_object
  , s.ksusesqh       sqlhash
  , s.ksusesql       sqladdr
  , s.ksusesph       planhash
  , s.ksusesch       sqlchild
  , s.ksusesqi       sqlid
from
    x$ksuprlat       lh
  , x$ksuse          s
where
    lh.ksuprsid = s.indx
and 1=0
/


create or replace package latchprof as
    procedure snap_latchholder(p_sleep in number default 1);
end latchprof;
/
show err

create or replace package body latchprof as

    procedure snap_latchholder(p_sleep in number default 1) as
    begin

        while true loop

          insert into latchprof_history
          select /*+ LEADING(lh) USE_NL(s) LATCHPROF_INSERT */
              systimestamp     sample_timestamp
            , lh.ksuprpid      pid
            , lh.ksuprsid      sid
            , lh.ksuprlat      child_address
            , lh.ksuprlnm      latch_name
            , lh.ksuprlmd      hold_mode
            , lh.ksulawhr      where_location
            , lh.ksulawhy      which_object
            , s.ksusesqh       sqlhash
            , s.ksusesql       sqladdr
            , s.ksusesph       planhash
            , s.ksusesch       sqlchild
            , s.ksusesqi       sqlid
          from
              x$ksuprlat       lh
            , x$ksuse          s
          where
              lh.ksuprsid = s.indx
          ;
          commit;

          dbms_lock.sleep(p_sleep);

      end loop; -- while true

  end snap_latchholder;

end latchprof;
/
show err

-- 9i version
create or replace view latchprof_view as
select
    h.sample_timestamp 
  , h.pid              
  , h.sid              
  , h.child_address    
  , h.latch_name 
  , h.hold_mode      
  , h.where_location   
  , h.which_object 
  , h.sqlid
  , h.sqlchild
  , h.planhash    
  , h.sqlhash          
  , h.sqladdr            
  , r.reason_name
  , r.reason_label
from
    latchprof_history h
  , latchprof_reasons r
where
    h.where_location = r.indx
/

