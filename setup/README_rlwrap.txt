An example alias I use for connecting through rlwrap:

alias sl='rlwrap -D2 -irc -b'\''"@(){}[],+=&^%#;|\'\'' -f ~/work/oracle/tpt/setup/wordfile_11gR2.txt sqlplus sys/oracle@linux01/lin11g as sysdba'

You may want to generate your own completion dictionary using wordfile_11gR2.sql example

"man rlwrap" command is your friend!

