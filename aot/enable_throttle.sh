#!/bin/bash

# Copyright 2020 Tanel Poder. All rights reserved. 
# Licensed under the Apache License, Version 2.0.

# Purpose: enable I/O throttling for a block device using cgroups
#
# Usage: find block device major:minor numbers using ls -l /dev or lsblk
#        ./enable_throttle.sh <major:minor> <max_iops> <max_bps>
#        ./enable_throttle.sh 259:3 500 100000000
#
# More info at https://tanelpoder.com

DEVICE_ID=$1
DEVICE_IOPS=$2
DEVICE_BPS=$3

echo $DEVICE_ID $DEVICE_IOPS > /sys/fs/cgroup/blkio/blkio.throttle.write_iops_device
echo $DEVICE_ID $DEVICE_IOPS > /sys/fs/cgroup/blkio/blkio.throttle.read_iops_device

echo $DEVICE_ID $DEVICE_BPS > /sys/fs/cgroup/blkio/blkio.throttle.write_bps_device
echo $DEVICE_ID $DEVICE_BPS > /sys/fs/cgroup/blkio/blkio.throttle.read_bps_device

grep . /sys/fs/cgroup/blkio/blkio.throttle*device

