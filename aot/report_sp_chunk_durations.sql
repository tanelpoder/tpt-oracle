prompt
prompt WARNING!!! This script will query X$KSMSP, which will cause heavy shared pool latch contention
prompt in systems under load and with large shared pool. This may even completely hang
prompt your instance until the query has finished! You probably do not want to run this in production!
prompt
pause  Press ENTER to continue, CTRL+C to cancel...

COL chunk_comment FOR A20
BREAK ON ksmchdur SKIP 1 DUPLICATES

SELECT
    ksmchdur
  , ksmchcls
  , SUBSTR(ksmchcom,1,DECODE(INSTR(ksmchcom,'^'),0,99,INSTR(ksmchcom,'^'))) chunk_comment
  , COUNT(*),MIN(ksmchsiz),MAX(ksmchsiz),SUM(ksmchsiz)
FROM 
    x$ksmsp 
GROUP BY 
    ksmchdur
  , ksmchcls
  , SUBSTR(ksmchcom,1,DECODE(INSTR(ksmchcom,'^'),0,99,INSTR(ksmchcom,'^')))
ORDER BY
    ksmchdur
  , SUM(ksmchsiz) DESC
/

