#!/bin/ksh
# Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
# Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

TRACEFILE=$1

sed -e '
s/</\&lt;/g
s/>/\&gt;/g
s/SO: \(0x[A-Fa-f0-9]*\)/<a name="#\1">SO: \1<\/a>/
s/LIBRARY HANDLE:\(0x[A-Fa-f0-9]*\)/<a name="#\1">LIBRARY HANDLE:\1<\/a>/
s/owner: \(0x[A-Fa-f0-9]*\)/owner: <a href="#\1">\1<\/a>/
s/handle=\(0x[A-Fa-f0-9]*\)/handle=<a href="#\1">\1<\/a>/
' $TRACEFILE | awk '
   BEGIN { print "<html><head><title>ssexplorer output</title></head><body><pre><code>" }
   { print $0 }
   END { print "</code></pre></body></html>" }
' > ~/blah.html


#awk '
#
#    BEGIN { print "<html><head><title>ssexplorer output</title></head><body><pre><code>" }
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
#' | awk '/SO: / { sub( /<a href=/, "<a name=" ) }' > ~/blah.html


