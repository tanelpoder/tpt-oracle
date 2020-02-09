#!/bin/bash

# Copyright 2020 Tanel Poder. All rights reserved. 
# Licensed under the Apache License, Version 2.0.

# Purpose: disable I/O throttling for a block device using cgroups
#
# Usage: find block device major:minor numbers using ls -l /dev or lsblk
#        ./disable_throttle.sh <major:minor> 
#        ./disable_throttle.sh 259:3 
#
# More info at https://tanelpoder.com

DEVICE_ID=$1
DEVICE_IOPS=0
DEVICE_BPS=0

echo $DEVICE_ID $DEVICE_IOPS > /sys/fs/cgroup/blkio/blkio.throttle.write_iops_device
echo $DEVICE_ID $DEVICE_IOPS > /sys/fs/cgroup/blkio/blkio.throttle.read_iops_device

echo $DEVICE_ID $DEVICE_BPS > /sys/fs/cgroup/blkio/blkio.throttle.write_bps_device
echo $DEVICE_ID $DEVICE_BPS > /sys/fs/cgroup/blkio/blkio.throttle.read_bps_device

grep . /sys/fs/cgroup/blkio/blkio.throttle*device

