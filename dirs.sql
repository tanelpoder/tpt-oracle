-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col dirs_directory_path head DIRECTORY_PATH for a90
col dirs_directory_name head DIRECTORY_NAME for a40 WRAP
col dirs_owner HEAD DIRECTORY_OWNER FOR A30
select directory_name dirs_directory_name, directory_path dirs_directory_path from dba_directories;
