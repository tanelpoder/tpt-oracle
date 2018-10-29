-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DEF ppxuser=AST
DEF oeuser=SOE

PROMPT Creating the user and tablespaces...

-- Create clone tables
@range_part
@range_hash_subpart
@range_id_part

