-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   f.sql
-- Purpose:     Search for Fixed view (V$ view) text
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @f <text>
--              @f sql_shared
--
--------------------------------------------------------------------------------

col view_name for a25 wrap
col text for a100 word_wrap

prompt Search for Fixed view (V$ view) with view name or text containing %&1%

select view_name, view_definition text from v$fixed_View_definition where upper(view_name) like upper('%&1%') or upper(view_definition) like upper('%&1%');

