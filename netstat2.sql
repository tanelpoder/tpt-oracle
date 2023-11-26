COL ksugblnetstatname HEAD STAT_NAME FOR A30
COL ksugblnetstatval  HEAD STAT_VALUE 
SELECT
    ksugblnetstatsid       sid 
  , ksugblnetstatser       ospid
  , ksugblnetstatname      
  , ksugblnetstatval       
FROM
    x$ksugblnetstat
WHERE
    ksugblnetstatval != 0
ORDER BY
    ksugblnetstatname
/

