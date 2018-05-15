-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   demo4.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--              Causes optimizer to loop in CBO code for very long time
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
-- Copyright:   (c) Tanel Poder
--
--------------------------------------------------------------------------------

prompt Starting demo4...

set termout off feedback off

drop table t;

create table t as select * from all_objects where 1=0;

exec dbms_stats.gather_table_stats(user,'T');
alter session set "_optimizer_search_limit"=100;

select * 
from 
 t t1
,t t2
,t t3
,t t4
,t t5
,t t6
,t t7
,t t8
,t t9
,t t10
,t t11
,t t12
,t t13
,t t14
,t t15
,t t16
,t t17
,t t18
,t t19
,t t20
,t t21
,t t22
,t t23
,t t24
,t t25
,t t26
,t t27
,t t28
,t t29
,t t30
,t t31
,t t32
,t t33
,t t34
,t t35
,t t36
,t t37
,t t38
,t t39
,t t40
,t t41
,t t42
,t t43
,t t44
,t t45
,t t46
,t t47
,t t48
,t t49
,t t50
,t t51
,t t52
,t t53
,t t54
,t t55
,t t56
,t t57
,t t58
,t t59
,t t60
,t t61
,t t62
,t t63
,t t64
,t t65
,t t66
,t t67
,t t68
,t t69
,t t70
,t t71
,t t72
,t t73
,t t74
,t t75
,t t76
,t t77
,t t78
,t t79
,t t80
,t t81
,t t82
,t t83
,t t84
,t t85
,t t86
,t t87
,t t88
,t t89
,t t90
,t t91
,t t92
,t t93
,t t94
,t t95
,t t96
,t t97
,t t98
,t t99
/

set termout on feedback on

