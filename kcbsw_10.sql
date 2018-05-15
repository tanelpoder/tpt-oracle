-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT * FROM (
	SELECT 
		dsc.kcbwhdes,
		sw.why0, 
		sw.why1,
		sw.why2,
		sw.other_wait
	FROM
		x$kcbwh		dsc,
		x$kcbsw		sw
	WHERE
		dsc.indx = sw.indx
	AND	sw.why0 + sw.why1 + sw.why2 + sw.other_wait > 0
	ORDER by
	--	dsc.kcbwhdes
		sw.why0 + sw.why1 + sw.why2 ASC
)
--WHERE rownum <= 10
/
