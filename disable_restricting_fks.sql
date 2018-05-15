-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT 'ALTER TABLE '||c.owner||'.'||c.table_name||' DISABLE CONSTRAINT '||c.constraint_name||';'
FROM dba_constraints c
WHERE (c.owner, c.constraint_name) IN (select a.owner, a.constraint_name 
                          FROM dba_constraints a, dba_constraints b
                          WHERE 
                              a.r_owner           = b.owner
                          AND a.r_constraint_name = b.constraint_name
                          AND a.constraint_type = 'R'
													AND UPPER(b.table_name) LIKE 
																	UPPER(CASE 
																		WHEN INSTR('&1','.') > 0 THEN 
																				SUBSTR('&1',INSTR('&1','.')+1)
																		ELSE
																				'&1'
																		END
																			 ) ESCAPE '\'
													AND UPPER(b.owner) LIKE
															CASE WHEN INSTR('&1','.') > 0 THEN
																UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
															ELSE
																user
                              END ESCAPE '\'
													)
/
