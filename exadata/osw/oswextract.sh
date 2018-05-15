#!/bin/bash

# Name:    oswextract.sh
# Purpose: Extract a specific metric from OS Watcher cellsrvstat archives
#
# Usage:
#   ./oswetract.sh "cellsrv metric to grep for" osw_archive_files_of_interest*.dat.bz2
#
# Example:
#   ./oswextract.sh "Number of latency threshold warnings for redo log writes" \
#                                    cell01.example.com_cellsrvstat_11.05.25.*.dat.bz2
#

METRIC=$1
shift
bzcat -q $* |
  egrep "Current Time|$METRIC" |
  awk '
cell01.example.com_cellsrvstat_11.05.25.*.dat.bz2
    BEGIN
      { printf("%-21s %20s %20s\n", "TIME", "CURRENT_VAL", "CUMULATIVE_VAL") }
    /Current/
      { printf("%s %s %s %s", $3, $4, $5, $6, $7) }
    /Number of latency threshold warnings for redo log writes/
      { printf("%20d %20d\n", $10, $11) }
  '
# end of script

