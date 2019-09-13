select
    la.addr laaddr,dc.kqrstcid CACHE#, dc.kqrsttxt PARAMETER,
    decode(dc.kqrsttyp, 1,'PARENT','SUBORDINATE') type,
    decode(dc.kqrsttyp, 2, kqrstsno, null) subordinate#,
    dc.kqrstgrq rcgets, dc.kqrstgmi rcmisses, dc.kqrstmrq rcmodifications,
    dc.kqrstmfl rcflushes, dc.kqrstcln,
    la.gets lagets, la.misses lamisses, la.immediate_gets laimge
from 
    x$kqrst dc
  , v$latch_children la
where 
     dc.inst_id = userenv('instance')
 and la.child# = dc.kqrstcln
 and la.name = 'row cache objects'
 and la.ADDR like '%33A1E7330'; <==== change the latch address to hex value of p1 for latch: row cache objects event
