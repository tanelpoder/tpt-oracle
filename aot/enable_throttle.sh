#!/bin/bash

# 259:3

DEVICE_ID=$1
DEVICE_IOPS=$2
DEVICE_BPS=$3

echo $DEVICE_ID $DEVICE_IOPS > /sys/fs/cgroup/blkio/blkio.throttle.write_iops_device
echo $DEVICE_ID $DEVICE_IOPS > /sys/fs/cgroup/blkio/blkio.throttle.read_iops_device

echo $DEVICE_ID $DEVICE_BPS > /sys/fs/cgroup/blkio/blkio.throttle.write_bps_device
echo $DEVICE_ID $DEVICE_BPS > /sys/fs/cgroup/blkio/blkio.throttle.read_bps_device

grep . /sys/fs/cgroup/blkio/blkio.throttle*device

