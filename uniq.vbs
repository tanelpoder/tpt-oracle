'-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
'-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
Dim curRow, prevRow, rowCount, lineSize

prevRow = ""
rowCount= 0
lineSize = 900

Set re1 = New RegExp
re1.Pattern = "\+[0-9]*"
re1.Global = True

Set re2 = New RegExp
re2.Pattern = ".*sspuser\(\)"
re2.Global = False
re2.IgnoreCase = True

Set re3 = New RegExp
re3.Pattern = ".*(" & WScript.Arguments.Item(0) & "\(\)<-)"
're3.Pattern = ".*<-(.*\(\)<-" & WScript.Arguments.Item(0) & "\(\)<-)"
re3.Global = False
re3.IgnoreCase = True


With WScript
    Do 
        curRow = re3.replace(re2.replace(re1.Replace(WScript.StdIn.ReadLine, ""),""), "$1")
        If rowCount = 0 Then prevRow = curRow

        rowCount = rowCount + 1
        If curRow <> prevRow Then 
            WScript.StdOut.WriteLine Space(6-Len(rowCount - 1)) & rowCount - 1 & " " & Space(lineSize-Len(prevRow)) & prevRow
            rowCount = 1
        End If
        prevRow = curRow
    Loop Until WScript.StdIn.AtEndOfStream
    WScript.StdOut.WriteLine Space(6-Len(rowCount)) & rowCount & " " & Space(lineSize-Len(prevRow)) & prevRow
End With
