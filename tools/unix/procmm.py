#!/bin/env python

# Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
# perms
# r = read
# w = write
# x = execute
# s = shared
# p = private (copy on write)

import sys, os, pwd, re, json

re_mapheader = re.compile('[0-9a-f]+-[0-9a-f]+', re.IGNORECASE)

def readFileLines(name):
    with file(name) as f:
        s = f.readlines()
    return s

def readFile(name):
    x=readFileLines(name)
    if x:
        return x[0]
    else:
        return None

def getProcRec(pid):
    try:
        mr={}
        mr['pid']         = pid
        mr['comm']        = readFile('/proc/' + pid + '/comm')
        mr['cmdline']     = readFile('/proc/' + pid + '/cmdline') 
        mr['username']    = pwd.getpwuid(os.stat('/proc/' + pid).st_uid).pw_name

    except IOError as e:
        print "Process gone"
    except Exception as e:
        print "error", e
        raise
    return mr

def getProcMemData(pid):
    memseg={}
    memdetail={}
    allmemseg={}
    allmemdetail={}
     
    try:
        for l in readFileLines('/proc/' + pid + '/smaps'):
            if re_mapheader.match(l):
                memseg['baddr_hex']  = l.split()[0].split('-')[0]
                memseg['eaddr_hex']  = l.split()[0].split('-')[1]
                memseg['perms']      = l.split()[1]
                memseg['offset']     = l.split()[2]
                memseg['dev']        = l.split()[3]
                memseg['inode']      = l.split()[4]
                if len(l.split()) >= 6:
                    s = l.split()[5]
                    if s.startswith('/dev/shm'):
                        s = '/dev/shm'
                        #re.sub('', '', s)
                        #print "s =", s
                    memseg['name'] = s
                else:
                    memseg['name'] = '[anon]'
                memseg['baddr']      = int(memseg['baddr_hex'], 16)
                memseg['eaddr']      = int(memseg['eaddr_hex'], 16)
                memseg['size']       = memseg['eaddr'] - memseg['baddr']

                allmemseg[memseg['name']] = memseg
            else:
                # smaps format example:
                # Size:                136 kB
                # Rss:                  40 kB ...
                memdetail[l.split()[0].replace(':','')] = memdetail.get(l.split()[0].replace(':',''), 0) + int(l.split()[1])
                
                allmemdetail[memseg['name']] = memdetail                

        return allmemseg, allmemdetail
             
    except IOError as e:
        print "Process gone"
    except Exception as e:
        print "error", e
        raise

def getProcMemDataSum(pidlist):
    memsum = {}
    for p in pidlist:
        procrec = getProcRec(p) 
        #print "\n============ PID: %d %s" % ( int(procrec['pid']), procrec['cmdline'].replace('\x00','')  )
        memseg, memdata = getProcMemData(p)
        #print memseg
        for ms in memseg:
            memsum[ms] = memdata[ms]
            #for i in memdata[ms]:
            #    #print "%-25s %10d kB %s" % (  i, memdata[ms][i], ms )  
            #    memsum[(ms,i)] = memsum.get((ms,i), 0) + memdata[ms][i]

    return memsum

def main(argv):
    memdatasum = getProcMemDataSum(argv) 
    #print memdatasum
    #print json.dumps(memdatasum, indent=4)
    print "%10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %s" % (
         'VSize'
       , 'PTE'
       , 'Locked'
       , 'MMUPages'
       , 'Priv_Clean'
       , 'Priv_Dirty'
       , 'Pss'
       , 'Referenced'
       , 'Rss'
       , 'Shr_Clean'
       , 'Shr_Dirty'
       , 'Swap'
       , ' Segment_Name'
    )
    print "%10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %s" % (
         '----------'
       , '----------'
       , '----------'
       , '----------'
       , '----------'
       , '----------'
       , '----------'
       , '----------'
       , '----------'
       , '----------'
       , '----------'
       , '----------'
       , ' ----------------------------------------------------------------------'
    )
    for mseg in memdatasum:
       m = memdatasum[mseg]
       print "%10d %10d %10d %10d %10d %10d %10d %10d %10d %10d %10d %10d  %s" % (
            m.get('Size', 0)
          , m.get('KernelPageSize', 0)
          , m.get('Locked', 0)
          , m.get('MMUPageSize', 0)
          , m.get('Private_Clean', 0)
          , m.get('Private_Dirty', 0)
          , m.get('Pss', 0)
          , m.get('Referenced', 0)
          , m.get('Rss', 0)
          , m.get('Shared_Clean', 0)
          , m.get('Shared_Dirty', 0)
          , m.get('Swap', 0)
          , mseg
       )

    #for a in argv:
    #    procrec = getProcRec(a) 
    #    print "\n============ PID: %d %s" % ( int(procrec['pid']), procrec['cmdline'].replace('\x00','')  )
    #    memseg, memdata = getProcMemData(a)
    #    #for i in sorted(memdata, key=memdata.get, reverse=False):
    #    for i in sorted(memdata, reverse=False):
    #        print "%-25s %10d kB" % (  i, memdata[i] )






if __name__ == "__main__":
    main(sys.argv[1:])

