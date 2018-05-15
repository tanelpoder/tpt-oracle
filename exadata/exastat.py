#!/usr/bin/env python
################################################################################
##
## File name:   exastat.py (v1.0)
## Purpose:     Show cumulative exadata metrics from CELLCLI and their deltas
##              in multicolumn format
##
## Author:      Tanel Poder ( tanel@tanelpoder.com | @tanelpoder | blog.tanelpoder.com )
## Copyright:   Tanel Poder. All Rights Reserved.
##
## Usage:       Save LIST METRICHISTORY into a file or pipe directly to exastat
##
## Example:     cellcli -e "LIST METRICHISTORY WHERE name LIKE 'FL_.*' AND collectionTime > '"`date --date \ 
##                 '1 day ago' "+%Y-%m-%dT%H:%M:%S%:z"`"'" | ./exastat FL_DISK_FIRST FL_FLASH_FIRST
##
##              The above example lists you two metrics FL_DISK_FIRST and FL_FLASH_FIRST in columnar format
##              You can list any number of metrics (you're not restricted to only two)
##
##
################################################################################

import fileinput, re, datetime, time, sys

DEBUG=False

rawmetrics = {}  # main metric array
errors = [] # unparsable lines
timestamps = []

cell_pattern = re.compile(r"^\s*(?P<name>\w+)\s+(?P<obj>\w+)\s+(?P<value>[\w,]+)\s(?P<unit>.*)\s+(?P<timestamp>.{25})$")

def extract_metric_value(s, pattern):
    match = pattern.match(s)

    if match:
        name      = match.group("name").strip()
        obj       = match.group("obj").strip()
        value     = int(match.group("value").strip().replace(',',''))
        unit      = match.group("unit").strip()
        timestamp = datetime.datetime.fromtimestamp(time.mktime(time.strptime(match.group("timestamp").strip()[:-6], "%Y-%m-%dT%H:%M:%S")))

        return {"METRIC_NAME":name, "METRIC_OBJECT":obj, "METRIC_VALUE":value, "METRIC_UNIT":unit, "TIMESTAMP":timestamp}

def get_timestamps(m):
    t = []
    for i in (key for key in sorted(m.keys(), key=lambda x: x[1])):
        if not t.__contains__(i[1]):
            t.append( i[1] )
    return t

def get_ordered_metric_values(m, metric_name):
    r = []
    for i in (key for key in sorted(m.keys(), key=lambda x: x[1]) if key[0]==metric_name):
        if DEBUG: print "key = %s value = %s" % (i, m[i])
        r.append({ "METRIC_NAME":i[0], "TIMESTAMP":i[1], "METRIC_OBJECT":i[2], "METRIC_VALUE":m[i]["METRIC_VALUE"], "METRIC_UNIT":m[i]["METRIC_UNIT"] })
    return r

def get_delta_metric_values(m, metric_name):
    r = {}
    prev_metric_value = None
    # requires ordered input
    for i in (key for key in (get_ordered_metric_values(m, metric_name))):
        if prev_metric_value:
            if DEBUG: print "%s delta %s = %s (%s - %s)" % ( i["TIMESTAMP"], i["METRIC_NAME"], i["METRIC_VALUE"] - prev_metric_value, i["METRIC_VALUE"], prev_metric_value )
            r[i["TIMESTAMP"]] = ( i["TIMESTAMP"], i["METRIC_NAME"], i["METRIC_VALUE"] - prev_metric_value, i["METRIC_VALUE"], prev_metric_value )
            prev_metric_value = i["METRIC_VALUE"]
        else:
            prev_metric_value = i["METRIC_VALUE"]
    return r

# main()
metric_list = sys.argv[1:]

for line in sys.stdin.readlines():
    e = extract_metric_value(line, cell_pattern)
    if e:
        if e["METRIC_NAME"] in metric_list:
            rawmetrics[e["METRIC_NAME"], e["TIMESTAMP"], e["METRIC_OBJECT"]] = { "METRIC_VALUE":e["METRIC_VALUE"], "METRIC_UNIT":e["METRIC_UNIT"] }
    else:
        errors.append(line) 

if DEBUG: print "len(rawmetrics) = %s len(errors) = %s" % (len(rawmetrics), len(errors))


m = {}
for mn in metric_list:
    m[mn] = get_delta_metric_values(rawmetrics, mn)

timestamps = get_timestamps(rawmetrics)
if DEBUG: print timestamps.pop(0) # 0-th sample doesn't have delta

output_header = ("%-26s %10s" % ("TIMESTAMP", "SECONDS"))
output_separator = "%-26s %10s" % ("-" * 26, "-" * 10)

for x in metric_list:
    output_header += ("%" + str(len(x)+1) +"s") % x
    output_separator += ' ' + '-' * len(x)

print ""
print output_header 
print output_separator

prev_ts = None
for ts in iter(timestamps):
    if prev_ts:
        out = "%-26s %10s" % (ts, (ts - prev_ts).seconds) 
        prev_ts = ts
    else:
        out = "%-26s %10s" % (ts, "") 
        prev_ts = ts

    for mn in metric_list:
        if ts in m[mn]:
            v = m[mn][ts][2]
        else:
            v = 0

        out += (" %"+str(len(mn)) +"d") % v
    
    print out

print ""

