#!/bin/bash

CMD="LIST ACTIVEREQUEST ATTRIBUTES name,asmDiskGroupNumber,asmFileIncarnation,asmFileNumber\
          ,consumerGroupID,consumerGroupName,dbID,dbName,dbRequestID,fileType,id,instanceNumber\
          ,ioBytes,ioBytesSofar,ioGridDisk,ioOffset,ioReason,ioType,objectNumber,parentID\
          ,requestState,sessionID,sessionSerNumber,sqlID,tableSpaceNumber"

CMD2="LIST ACTIVEREQUEST DETAIL"

echo set echo on

while true ; do
    echo REM TIME `date +"%Y-%m-%d %H:%M:%S"`
    echo $CMD2
    sleep 1
done
