-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col bhobjects_owner head OWNER for a30
col bhobjects_object_name head OBJECT_NAME for a30
col bhobjects_subobject_name head SUBOBJECT_NAME for a30
col bhobjects_object_type head OBJECT_TYPE for a20 word_wrap



select * from (
    select
        count(*) buffers
      , o.owner                bhobjects_owner
      , o.object_name          bhobjects_object_name
      , o.subobject_name       bhobjects_subobject_name
      , o.object_type          bhobjects_object_type
    from
        v$bh bh
      , dba_objects o
    where 
        bh.objd = o.data_object_id
    group by
        o.owner, o.object_name, o.subobject_name, o.object_type
    order by 
        buffers desc
)
where rownum <=30
/

