/*   
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   Purpose:

   generate an optimizer trace from the cursor cache. Removes the need to 
   purge the cursor or force a hard parse
*/

PRO 
PRO Generate an optimizer trace from the cursor cache
PRO

ACC v_sql_id PROMPT 'Enter your SQL ID: '

PRO checking cursor cache for SQL ID &v_sql_id

select sql_id, plan_hash_value, child_number from gv$sql where sql_id = '&v_sql_id';

ACC v_child_number PROMPT 'Enter the child cursor number: '

BEGIN
    sys.DBMS_SQLDIAG.DUMP_TRACE(
        p_sql_id => '&v_sql_id',
        p_child_number => &v_child_number,
        p_component => 'Compiler'
    );
END;
/

select 'Trace file: ' || value tracefile from v$diag_info where name like 'Def%';