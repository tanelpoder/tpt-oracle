-- taken from metalink note 396940.1
-- customized by Tanel 

prompt
prompt WARNING!!! This script will query X$KSMSP, which will cause heavy shared pool latch contention 
prompt in systems under load and with large shared pool. This may even completely hang 
prompt your instance until the query has finished! You probably do not want to run this in production!
prompt
pause  Press ENTER to continue, CTRL+C to cancel...


col sga_heap format a15 
col size format a10 
col chunkcomment for a25

break on subpool on duration on sga_heap skip 1 on status skip 1 on chunkcomment

select 
	KSMCHIDX subpool, 
  KSMCHDUR duration,
	'sga heap('||KSMCHIDX||','||KSMCHDUR||')' sga_heap,
	ksmchcls Status, 
	substr(ksmchcom,1,decode(instr(ksmchcom,'^'),0,99,instr(ksmchcom,'^'))) ChunkComment,
	decode(trunc(ksmchsiz/1024),
		0,'0-1K', 
		1,'1-2K', 
		2,'2-3K',
		3,'3-4K', 
		4,'4-5K',
		5,'5-6k',
		6,'6-7k',
		7,'7-8k',
		8,'8-9k', 
		9,'9-10k',
		'> 10K') "SIZE", 
	count(*),
	sum(ksmchsiz) "SUM(BYTES)",
	min(ksmchsiz) MinBytes, 
	max(ksmchsiz) MaxBytes,
	trunc(avg(ksmchsiz)) AvgBytes 
from 
	x$ksmsp 
where 
	1=1
and	lower(KSMCHCOM) like lower('%&1%')
group by 
	ksmchidx, 
  ksmchdur,
	ksmchcls,
--	'sga heap('||KSMCHIDX||','||KSMCHDUR'||)',
	substr(ksmchcom,1,decode(instr(ksmchcom,'^'),0,99,instr(ksmchcom,'^'))),
	decode(trunc(ksmchsiz/1024),0,'0-1K',1,'1-2K', 2,'2-3K', 3,'3-4K',4,'4-5K',5,'5-6k',
		6, '6-7k',7,'7-8k',8,'8-9k', 9,'9-10k','> 10K')
order by
	ksmchidx,
  ksmchdur,
	ksmchcls,
	lower(substr(ksmchcom,1,decode(instr(ksmchcom,'^'),0,99,instr(ksmchcom,'^')))),
	"SIZE"
/



