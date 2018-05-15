-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show invalid objects, indexes, index partitions and index subpartitions....

col ind_owner head OWNER for a20
col inv_oname head OBJECT_NAME for a30

select owner ind_owner, object_name inv_oname, object_type from dba_objects where status != 'VALID';

select owner ind_owner, table_name, index_name from dba_indexes where status not in ('VALID', 'N/A');

select index_owner ind_owner, index_name, partition_name from dba_ind_partitions where status not in ('N/A', 'USABLE');

select indeX_owner ind_owner, index_name, partition_name, subpartition_name from dba_ind_subpartitions where status not in ('USABLE');

