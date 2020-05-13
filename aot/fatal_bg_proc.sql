-- a simple script for (hopefully) showing just the "fatal" background
-- processes. when these processes disappear, it  will bring the whole
-- database instance down. other processes are typically just restarted

SELECT indx,ksuprpnm,TO_CHAR(ksuprflg,'XXXXXXXXXXXXXXXX')
FROM x$ksupr
WHERE BITAND(ksuprflg,4) = 4 ORDER BY indx
/

