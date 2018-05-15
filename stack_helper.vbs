' Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
' Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
'-------------------------------------------------------------------------------------
'--
'-- File name:   stack_helper.vbs v1.01
'-- Purpose:     Helper script for OStackProf.sql script
'--
'-- Author:      Tanel Poder
'-- Copyright:   (c) http://www.tanelpoder.com
'--              
'-- Usage:       Put it into the same directory where %SQLPATH% environment variable
'--              points. OStackProf will call it for post-processing stack traces.
'--
'-------------------------------------------------------------------------------------

Option Explicit

Dim DEBUG
DEBUG=False

Dim curRow, prevRow, rowCount, commonFuncIndex, funcList, prevFuncList, rowsProcessed
Dim re1, re2, re3, re4, re5

prevRow = ""
rowCount= 0

Set re1 = New RegExp
re1.Pattern = "\+[0-9]*"
re1.Global = True

Set re2 = New RegExp
re2.Pattern = ".*sspuser\(\)|.*00000000<-"
re2.Global = False
re2.IgnoreCase = True

'Set re2a = New RegExp
're2a.Pattern = "<-_[a-z]"
're2a.Global = True
're2a.IgnoreCase = True

'Set re3 = New RegExp
're3.Pattern = ".*(" & WScript.Arguments.Item(0) & "\(\)<-)"
're3.Pattern = ".*<-(.*\(\)<-" & WScript.Arguments.Item(0) & "\(\)<-)"
're3.Global = False
're3.IgnoreCase = True

Set re4 = New RegExp
're4.Pattern = "<-(.*?\(\))"
re4.Pattern = "(.*?)<-"
re4.Global = True
re4.IgnoreCase = True

Set re5 = New RegExp
re5.Pattern = "^<-|<-$"
re5.Global = False
re5.IgnoreCase = True

'-----------------------------------------------------------------------------------------------------
Function stackStrip()
    Dim rowIndex
    rowIndex = 0
    
    With WScript
        Do 
            rowIndex = rowIndex + 1
            'curRow = re3.replace(re2.replace(re1.Replace(WScript.StdIn.ReadLine, ""),""), "$1")
            WScript.StdOut.WriteLine re2.replace(re1.Replace(WScript.StdIn.ReadLine, ""),"")
        Loop Until WScript.StdIn.AtEndOfStream
    End With

    stackStrip=rowIndex
End Function

'-----------------------------------------------------------------------------------------------------
Function printFuncSummary(f, startFrom)
    Dim i,j
    WScript.StdOut.WriteLine "# -#--------------------------------------------------------------------"   
    WScript.StdOut.WriteLine "# - Num.Samples -> in call stack()                                      "   
    WScript.StdOut.WriteLine "# ----------------------------------------------------------------------"   
    
    
    'j = f.Count - 1 - startFrom
    For i = f.Count - 1 To f.Count - startFrom step -1
        WScript.StdOut.WriteLine "#" & Space(3-Len(i-1)) & i-1 & Space(f.Count - i) & "->" & re5.replace(f(i), "")
        
    Next
    WScript.StdOut.WriteLine "#  ...(see call profile below)"
    WScript.StdOut.WriteLine "#      "
End Function

'-----------------------------------------------------------------------------------------------------
Function printFuncList(f, startFrom, cnt)
    Dim i,j
    WScript.StdOut.Write Space(6-Len(cnt)) & cnt & " ->"            
    
    'j = f.Count - 1 - startFrom
    For i = f.Count - 1 - startFrom To 0 step -1
        WScript.StdOut.Write re5.replace(f(i), "") & "->"
    Next
    WScript.StdOut.WriteLine ""
End Function

'-----------------------------------------------------------------------------------------------------
Function getCommonFuncIndex(f1, f2, index)
    Dim i,tmp
    For i = 1 To index
        If DEBUG Then WScript.StdOut.WriteLine "     i: " & i & "    f1.count=" & f1.count & "    f2.count=" & f2.count 
        If DEBUG Then WScript.StdOut.WriteLine "fields: " & i & ":" & f1(f1.count - i) & " , " & f2(f2.count - i)
        If i >= f1.Count Or i >= f2.Count Or StrComp(f1(f1.count-i),f2(f2.count-i)) <> 0 Then 
            getCommonFuncIndex = i - 1
            Exit For
        End If
    Next
    If DEBUG Then tmp=printFuncList(f1,0,f1.count-1)
    If DEBUG Then WScript.StdOut.WriteLine "Common idx: " & i
    getCommonFuncIndex = i - 1
End Function

'-----------------------------------------------------------------------------------------------------
Function stackReport()
    Dim rowIndex
    Dim i,tmp,longestStack
    Dim rows()
    ReDim rows(100)
    
    '-- init row array and find highest common prefix across all stacks
    rowIndex = 0
    Do
        rows(rowIndex)=WScript.StdIn.ReadLine
            
        If rowIndex = 0 Then 
            Set prevFuncList = re4.Execute(rows(0))
            commonFuncIndex = prevFuncList.Count-1
            Set longestStack = prevFuncList
        Else
            Set funcList = re4.Execute(rows(rowIndex))
            commonFuncIndex = getCommonFuncIndex(funcList, prevFuncList, commonFuncIndex)
            If funcList.Count > prevFuncList.Count Then Set longestStack = funcList
        End If

        rowIndex = rowIndex + 1
        If rowIndex >= 100 Then ReDim Preserve rows(rowIndex+1)
        
    Loop Until WScript.StdIn.AtEndOfStream

    If DEBUG Then WScript.StdOut.WriteLine "rowIndex: " & rowIndex

    If rowIndex < 2 Then 
        WScript.StdOut.WriteLine "ERROR: Not enough stack samples"
        WScript.Quit(1)
    End If
        
    '-- print common stack prefix
    tmp = printFuncSummary(longestStack, commonFuncIndex)
    
    '-- loop & print stack line breakdown
    With WScript
        For i = 0 To rowIndex - 1
            curRow = rows(i)
            If rowCount = 0 Then 
                prevRow = curRow
                Set prevFuncList = re4.Execute(prevRow)
            End If
    
            rowCount = rowCount + 1
            If curRow <> prevRow Then 
               Set funcList = re4.Execute(prevRow)
               tmp = printFuncList(funcList, commonFuncIndex,rowCount-1)
               Set prevFuncList = funcList
               rowCount = 1
            End If
            prevRow = curRow
        Next

        ' 1.01 fix
        Set funcList = re4.Execute(prevRow)
        tmp = printFuncList(funcList, commonFuncIndex, rowCount)
    End With

    stackReport=rowIndex
End Function


'-----------------------------------------------------------------------------------------------------
' main()
'-----------------------------------------------------------------------------------------------------
If LCase(WScript.Arguments.Item(0)) = "-report" Then 
    rowsProcessed = stackReport()
ElseIf LCase(WScript.Arguments.Item(0)) = "-strip" Then 
    rowsProcessed = stackStrip()
Else
    WScript.StdOut.WriteLine ""
    WScript.StdOut.WriteLine "Usage: "
    WScript.StdOut.WriteLine "    cscript //nologo %SQLPATH%\stack_helper.vbs <action>"
    WScript.StdOut.WriteLine ""
    WScript.StdOut.WriteLine "    action is either -report or -strip"
    WScript.StdOut.WriteLine ""
    WScript.Quit(1)
End If

'-----------------------------------------------------------------------------------------------------
'end
'-----------------------------------------------------------------------------------------------------
