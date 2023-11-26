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
    ksugblnetstatsid IN (&1)
ORDER BY
    ksugblnetstatsid 
  , ksugblnetstatname
    ksugblnetstatval != 0
/

