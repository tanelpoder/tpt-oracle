SELECT 
  partition_name, header_file, header_block, header_block+1 root_block   
 ,TO_CHAR(DBMS_UTILITY.MAKE_DATA_BLOCK_ADDRESS(header_file,header_block+1), '0XXXXXXXXXXXXXXX') root_hex
FROM dba_segments 
WHERE owner = '&1' 
AND segment_name = '&2'
/
