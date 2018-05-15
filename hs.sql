-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set termout off

set markup HTML ON 
-- HEAD "<style type='text/css'> body {font:10pt Arial,Helvetica,sans-serif; color:black; background:White; } p {font:10pt Arial,Helvetica,sans-serif; color:black; background:White; white-space: nowrap; } table,tr,td {font:10pt Courier New,Courier,fixed,Arial,Helvetica,sans-serif; color:Black; background:#f7f7e7; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px; white-space: nowrap;} th {font:bold 10pt Arial,Helvetica,sans-serif; color:#336699; background:#cccc99; padding:0px 0px 0px 0px;} h1 {font:16pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} h2 {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} a {font:9pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}</style><title>&1</title>" BODY "" TABLE "border='1' align='center' summary='Script output'" SPOOL ON ENTMAP OFF PREFORMAT OFF

define _tptmode=html

def _hs_spoolfile=&_tpt_tempdir/htmlrun_&_tpt_tempfile..html

spool &_hs_spoolfile

@&1

spool off
set markup html off spool off
define _tptmode=normal

host &_start &_hs_spoolfile
set termout on
