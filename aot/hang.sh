#!/bin/bash

sqlplus $1 @hang_1.sql &
sleep 3
sqlplus $1 @hang_2.sql &
sleep 3
sqlplus $1 @hang_3.sql &
sleep 3
sqlplus $1 @hang_4.sql &

