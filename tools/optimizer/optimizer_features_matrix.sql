-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

PROMPT display a matrix of optimizer parameters which change when changing optimizer_features_enabled...

CREATE TABLE opt_param_matrix(
    opt_features_enabled VARCHAR2(20) NOT NULL
  , parameter            VARCHAR2(75) NOT NULL
  , value                VARCHAR2(1000)
)
/

CREATE TABLE opt_fix_matrix (
    opt_features_enabled VARCHAR2(20) NOT NULL
  , bugno                    NUMBER       
  , value                    NUMBER
  , sql_feature              VARCHAR2(100)
  , description              VARCHAR2(100)
  , optimizer_feature_enable VARCHAR2(25)
  , event                    NUMBER
  , is_default               NUMBER
)
/
 
BEGIN
    FOR i IN (select value from v$parameter_valid_values where name = 'optimizer_features_enable' order by ordinal) LOOP
        EXECUTE IMMEDIATE 'alter session set optimizer_features_enable='''||i.value||'''';
        EXECUTE IMMEDIATE 'insert into opt_param_matrix select :opt_features_enable, n.ksppinm, c.ksppstvl from sys.x$ksppi n, sys.x$ksppcv c where n.indx=c.indx' using i.value;
        EXECUTE IMMEDIATE 'insert into opt_fix_matrix   select :opt_features_enable, bugno, value, sql_feature, description, optimizer_feature_enable, event, is_default FROM v$session_fix_control WHERE session_id=USERENV(''sid'')' using i.value;
    END LOOP;
END;
/

COMMIT;

PROMPT To test, run: @cofep.sql 10.2.0.1 10.2.0.4

