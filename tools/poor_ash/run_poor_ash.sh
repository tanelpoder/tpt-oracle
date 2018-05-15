#!/bin/bash

./poor_ash.sh | sqlplus "/ as sysasm" > log_poor_ash.txt

