select * from gv$qmon_tasks order by inst_id, task_type, task_name, task_number; 

select inst_id, queue_schema, queue_name, queue_id, queue_state, startup_time, 
       num_msgs, spill_msgs, waiting, ready, expired, cnum_msgs, cspill_msgs, expired_msgs,
       total_wait, average_wait
from gv$buffered_queues, gv$aq
where queue_id=qid
order by 1,2,3;


