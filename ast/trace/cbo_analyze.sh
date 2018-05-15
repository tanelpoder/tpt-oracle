#!/bin/sh

cat $1 | awk '

function p(str) { printf("%6d: %s\n", NR, str) ; return 0 }

/Now joining|Join order/{ p($0) } 

/^Best::/{ x=1 ; p($0) } 

(!/Best::/ && x ==1) { p($0) ; x=0 }

' 
