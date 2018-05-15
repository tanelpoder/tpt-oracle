-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- get_compression_type runs recursive queries for every row analyzed, so it is extremely inefficient to run for analyzing many rows

SELECT
    COUNT(*)
  , DECODE( SYS.DBMS_COMPRESSION.GET_COMPRESSION_TYPE(USER, UPPER('&1'), ROWID),
      1, 'No Compression',
      2, 'Basic/OLTP Compression', 
      4, 'HCC Query High',
      8, 'HCC Query Low',
      16, 'HCC Archive High',
      32, 'HCC Archive Low',
      64, 'COMP_BLOCK ZFS?',
      'Unknown Compression Level'
    ) AS comp_type
FROM 
    &1
WHERE rownum <= &2
GROUP BY
    DECODE( SYS.DBMS_COMPRESSION.GET_COMPRESSION_TYPE(USER, UPPER('&1'), ROWID),
      1, 'No Compression',
      2, 'Basic/OLTP Compression', 
      4, 'HCC Query High',
      8, 'HCC Query Low',
      16, 'HCC Archive High',
      32, 'HCC Archive Low',
      64, 'COMP_BLOCK ZFS?',
      'Unknown Compression Level'
    )
/

