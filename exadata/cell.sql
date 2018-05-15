-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL cell_cell_path HEAD CELL_PATH FOR A30

SELECT
    c.cell_path  cell_cell_path
  , c.cell_hashval
FROM
    v$cell c
/

