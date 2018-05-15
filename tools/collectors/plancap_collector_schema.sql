-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- drop table plancap$data_files;
-- drop table plancap$free_space;
-- drop table plancap$segment_space;

CREATE TABLE plancap$data_files (
    snap_time                                DATE          NOT NULL
  , tablespace_name                          VARCHAR2(100) NOT NULL
  , file_id                                  NUMBER        NOT NULL
  , bytes                                    NUMBER        NOT NULL
  , blocks                                   NUMBER        NOT NULL
  , relative_fno                             NUMBER        NOT NULL
);

ALTER TABLE plancap$data_files ADD CONSTRAINT pk_data_files 
PRIMARY KEY (snap_time,tablespace_name,file_id);

CREATE TABLE plancap$free_space (
    snap_time                                DATE          NOT NULL
  , tablespace_name                          VARCHAR2(100) NOT NULL
  , file_id                                  NUMBER        NOT NULL
  , bytes                                    NUMBER        NOT NULL
  , blocks                                   NUMBER        NOT NULL
  , relative_fno                             NUMBER        NOT NULL
);

ALTER TABLE plancap$free_space ADD CONSTRAINT pk_free_space 
PRIMARY KEY (snap_time,tablespace_name,file_id);


CREATE TABLE plancap$segment_space(
    snap_time                                 DATE          NOT NULL
  , owner                                     VARCHAR2(100) NOT NULL
  , segment_name                              VARCHAR2(100) NOT NULL
  , partition_name                            VARCHAR2(100) NOT NULL
  , segment_type                              VARCHAR2(100) NOT NULL
  , tablespace_name                           VARCHAR2(100) NOT NULL
  , bytes                                     NUMBER        NOT NULL
  , blocks                                    NUMBER        NOT NULL
  , extents                                   NUMBER        NOT NULL
);

ALTER TABLE plancap$segment_space ADD CONSTRAINT pk_segment_space 
PRIMARY KEY (snap_time,owner,segment_name,partition_name,segment_type);

CREATE TABLE plancap$service_stats (
    snap_time                                 DATE          NOT NULL
  , service_name                              VARCHAR2(100) NOT NULL
  , db_cpu                                    NUMBER        NOT NULL
  , execute_count                             NUMBER        NOT NULL
  , user_commits                              NUMBER        NOT NULL
  , user_calls                                NUMBER        NOT NULL
);

ALTER TABLE plancap$service_stats ADD CONSTRAINT pk_service_stats 
PRIMARY KEY (snap_time,service_name);


CREATE PUBLIC SYNONYM plancap$data_files    FOR plancap$data_files;
CREATE PUBLIC SYNONYM plancap$free_space    FOR plancap$free_space;
CREATE PUBLIC SYNONYM plancap$segment_space FOR plancap$segment_space;

GRANT SELECT ON plancap$data_files    to DBA;
GRANT SELECT ON plancap$free_space    to DBA;
GRANT SELECT ON plancap$segment_space to DBA;
