SELECT time_stamp,pid,slvid,pname,sid,server_set,comp,filename,line,func,TRANSLATE(trace, CHR(10)||CHR(9), '  ') trace FROM gv$px_process_trace ORDER BY time_stamp ASC;
