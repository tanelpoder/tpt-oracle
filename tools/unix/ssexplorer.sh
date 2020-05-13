#!/usr/bin/env bash

# System State Dump "explorer"
# It just adds links to parent State Object location in the file for easier navigation

# Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

TRACEFILE=$1
OUTPUTFILE=$1.html

sed -e '
s/</\&lt;/g
s/>/\&gt;/g
s/SO: \(0x[A-Fa-f0-9]*\)/<a name="\1"><mark>SO: \1<\/mark><\/a>/
s/LIBRARY HANDLE:\(0x[A-Fa-f0-9]*\)/<a name="\1">LIBRARY HANDLE:\1<\/a>/
s/owner: \(0x[A-Fa-f0-9]*\)/owner: <a href="#\1">\1<\/a>/
s/handle=\(0x[A-Fa-f0-9]*\)/handle=<a href="#\1">\1<\/a>/
' $TRACEFILE | awk '
   BEGIN { print "<html><head><title>System State Dump Explorer by Tanel Poder</title></head><body><pre><code>" }
   { print $0 }
   END { print "</code></pre></body></html>" }
' > $OUTPUTFILE

echo Done writing into $OUTPUTFILE
echo
ls -l $OUTPUTFILE


#awk '
#
#    BEGIN { print "<html><head><title>System State Dump Explorer by Tanel Poder</title></head><body><pre><code>" }
#    
#    /0x[A-Fa-f0-9]/ { gsub( /(0x[A-Fa-f0-9]*)/, "<a href=\"#&\">&</a>", $0 ) }
#     
##    /SO: 0x[A-Za-z0-9]/ {
##        match($0, /(0x[A-Fa-f0-9]*),/ , arr)
##        printf ("<a name=\"%s\"></a>%s\n", arr[1], gsub( /(0x[A-Fa-f0-9]*)/, "<a href=\"#&\">&</a>", $0 ) )
##        
##    }
##    !/SO: 0x[A-Fa-f0-9]/ { gsub(/(0x[A-Fa-f0-9]*)/, "<a href=\"#&\">&</a>", $0) ; printf("%s\n", $0)  }
#    
#    
#    END { print "</code></pre></body></html>" }
#    
#
#' | awk '/SO: / { sub( /<a href=/, "<a name=" ) }' > > $1.html


