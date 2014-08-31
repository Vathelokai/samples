Attribute VB_Name = "LateListDelta4"
Public myRunData(8, 1) As String

' ############## Need to rework this so that it uses database connection instead of importing spreadsheets

Public Sub LateListStartup()
    
    Dim result As Variant
    
    ' have to load data before topOfFunction can read it
    result = getDefaultRunData()
    
    result = topOfFunction()
    ' this array will contain keys in column 0 and values in column 1:
    '   abort (true/false, quit now)
    '   myAutoMode (true/false, ask for user input)
    '   myDebugMode (true/false, verbose output while running)
    '   dDate (string version of late date)
    '   lDate (numberic unix date)
    '   lXOFileName (full path and file name to raw data)
    '   RevFileName (full path and file name to raw data)
    '   TempFileName (full path and file name to temp spreadsheet)
    '   OutputFileName (full path and file name to deliverable)
    
'    If Application.Workbooks.Count = 0 Then
        Application.Workbooks.Add
'    ElseIf Application.Workbooks.Count = 1 And Left$(Application.Workbooks(1).Name, 9) = "PERSONAL." Then
'        Application.Workbooks.Add
'    ElseIf Application.Workbooks.Count = 2 And _
'        (Left$(Application.Workbooks(1).Name, 9) = "PERSONAL." Or Left$(Application.Workbooks(2).Name, 9) = "PERSONAL.") _
'        And _
'        (Left$(Application.Workbooks(1).Name, 4) = "Book" Or Left$(Application.Workbooks(2).Name, 4) = "Book") _
'        Then
'        Application.Workbooks.Add
'    ElseIf Application.Workbooks.Count > 2 Then
'        result = setRunData("abort", "True")
'        MsgBox "Please close open workbooks", vbOKOnly
'    End If

    ' run in auto mode?
    If getRunData("myAutoMode") = False Then
        ' then prompt user
        result = userStartup2()
        
    ElseIf getRunData("myAutoMode") = True Then
        ' else, use defaults
    Else
        MsgBox "Something has gone very wrong (misplaced data).  Ending macro."
        Exit Sub
    End If
    
    ' abort?
    If getRunData("abort") = True Then
        MsgBox "user startup aborted"
        Exit Sub
    ElseIf getRunData("abort") = False Then
        'run with this data
        result = validateRunData()
        If result = True Then
            ' make sure workbook has correct sheet count and names
            result = prepareWorkbook()
    
            ' import the raw data
            result = importParadoxExports()
    
            ' clean up the data
            result = labelImports()
            result = formatImports()
    
            ' build overview page
            result = buildOverview()
    
            ' calculate everything
            result = generateNumbers()
    
            ' save book
            result = saveLateList()
        ElseIf result = False Then
            ' data is invalid
            MsgBox "RunData has not passed validity test.  Ending macro."
            Exit Sub
        Else
            MsgBox "Something has gone very wrong (misplaced data).  Ending macro."
            Exit Sub
        End If
    Else
        MsgBox "Something has gone very wrong (misplaced data).  Ending macro."
        Exit Sub
    End If
    
    If getRunData("myAutoMode") = False Then
        MsgBox "Macro is complete.  Late List is on Desktop.", vbOKOnly
    End If
    
    If getRunData("myDebugMode") = False Then
        ActiveWorkbook.Close
    End If

    Application.ScreenUpdating = True
    Application.DisplayAlerts = True
    Application.StatusBar = False
    'result = BottomOfFunction()

End Sub

Function getDefaultRunData() As Boolean

    Dim stringDate As Date ' the Late cutoff date
    Dim numberDate As Long ' unix date value of numberDate
    Dim pickupLocation As String ' where to find raw data by default
    Dim dropoffLocation As String ' where to deposit late list by default
    pickupLocation = Environ("UserProfile") & "\Desktop\"
    dropoffLocation = pickupLocation
    'pickupLocation = "\\Hr-s1\CMS\Core Team\Metric_Generation\in\"
    'dropoffLocation = "\\Hr-s1\CMS\Core Team\Metric_Generation\out\Late_List\"

    ' set default data
    ' this array will contain keys in column 0 and values in column 1
    ' the getRunData() and setRunData() functions are used to treat this
    '   array as though it were a hash


    '   abort (true/false, quit now)
    myRunData(0, 0) = "abort"
    myRunData(0, 1) = "False"
    
    '   myAutoMode (true/false, ask for user input)
    myRunData(1, 0) = "myAutoMode"
    myRunData(1, 1) = "False"
    
    '   myDebugMode (true/false, verbose output while running)
    myRunData(2, 0) = "myDebugMode"
    myRunData(2, 1) = "True"
    
    '   TempFileName (full path and file name to temp spreadsheet)
    ' note, this is not used in newer versions of this macro
    myRunData(3, 0) = "TempFileName"
    myRunData(3, 1) = "c:\temp\late-list-temp.xls"
    
    '   stringDate (string version of late date)
    myRunData(4, 0) = "stringDate"
    ' stringDate is a date object and accepts formatting
    Dim timeOfDay As Double ' makes a percentage of hours passed in the day
    timeOfDay = TimeValue(Now)
    ' if before noon, use yesterday's date; afternoon use today's date
    If timeOfDay > 0.5 Then
        stringDate = DateSerial(Year(Now()), Month(Now()), Day(Now()))
    ElseIf timeOfDay <= 0.5 Then
        stringDate = DateSerial(Year(Now()), Month(Now()), Day(Now()) - 1)
    End If
    myRunData(4, 1) = stringDate

    '   numberDate (numeric unix date)
    myRunData(5, 0) = "numberDate"
    ' numberDate is a long integer, and converts to unix date value automatically
    numberDate = stringDate
    myRunData(5, 1) = numberDate

    '   lXOFileName (full path and file name to raw data)
    myRunData(6, 0) = "lXOFileName"
    myRunData(6, 1) = pickupLocation & "manuscripts.xls"

    '   RevFileName (full path and file name to raw data)
    myRunData(7, 0) = "RevFileName"
    myRunData(7, 1) = pickupLocation & "revisions.xls"

    '   OutputFileName (full path and file name to deliverable)
    myRunData(8, 0) = "OutputFileName"
    'myRunData(8, 1) = Environ("UserProfile") & "\Desktop\Late-List-" & Format(myRunData(4, 1), "dd-mmm-yyyy") & ".xls"
    myRunData(8, 1) = dropoffLocation & "Late-List-" & Format(myRunData(4, 1), "dd-mmm-yyyy") & "_" & Format(Now(), "hAMPM") & ".xls"

    getDefaultRunData = True

End Function

Function userStartup2()

    result = topOfFunction("Asking Questions...")
    
    Dim intResponse As Integer
    Dim strDate As String
    Dim stringDate As Date
    Dim numberDate As Long
    Dim lXOFileName As String
    Dim RevFileName As String
    
    'A simple hello and reminder message
    intResponse = MsgBox(Prompt:="Please ensure that you have the 1XO" & _
        "and Revision exports availiable." & vbCrLf & vbCrLf & _
        vbTab & vbTab & "        Are your files ready?", _
        Buttons:=vbYesNo, Title:="Late List Production Macro")
    If intResponse = vbNo Then
        GoTo abortStartup
    End If
    
    MsgBox ("Please select the 1XO Export spreadsheet.")
    lXOFileName = Application.GetOpenFilename ' This command stops the debugger and changes to full run mode
    myRunData(6, 1) = lXOFileName
    If lXOFileName = "False" Then
        intResponse = MsgBox(Prompt:="  No 1XO file selected." & vbCrLf & vbCrLf & "Please restart macro.", Buttons:=vbOKOnly)
        GoTo abortStartup
    End If

    MsgBox ("Please select the Revision Export spreadsheet.")
    RevFileName = Application.GetOpenFilename ' This command stops the debugger and changes to full run mode
    myRunData(7, 1) = RevFileName
    If RevFileName = "False" Then
        intResponse = MsgBox(Prompt:="  No Rev file selected." & vbCrLf & vbCrLf & "Please restart macro.", Buttons:=vbOKOnly)
        GoTo abortStartup
    End If

    result = BottomOfFunction()

Exit Function

abortStartup:
    myRunData(0, 1) = "True"
    
    result = BottomOfFunction()

End Function
Function validateRunData() As Boolean
    
    result = topOfFunction("Validating RunData...")
    
    validateRunData = True
    
    ' Check True/False values (1,2,3)
    ' these are strings because the array is strings, but they should be boolean values
    If _
        myRunData(0, 1) <> True And myRunData(0, 1) <> False And _
        myRunData(1, 1) <> True And myRunData(1, 1) <> False And _
        myRunData(2, 1) <> True And myRunData(2, 1) <> False _
    Then
        validateRunData = False
        MsgBox "One of the following values was not set: Run Mode, Abort?, or Debug Mode.", vbOKOnly
    End If

    ' Check filepaths 3,6,7,8
    ' there should be no temp file to work with yet
    'If Not Dir(myRunData(3, 1), vbDirectory) = vbNullString Then
    '    validateRunData = False
    'End If
    
    ' the manuscript export should be present
    If Dir(myRunData(6, 1), vbDirectory) = vbNullString Then
        validateRunData = False
        MsgBox "No Manuscript data found.", vbOKOnly
    End If
    
    ' the revision export should be present
    If Dir(myRunData(7, 1), vbDirectory) = vbNullString Then
        validateRunData = False
        MsgBox "No Revision data found.", vbOKOnly
    End If
    
    ' a file with the default output name should not exist yet
    If Not Dir(myRunData(8, 1), vbDirectory) = vbNullString Then
        ' allowing overwrite for now
        'validateRunData = False
        'MsgBox "A file with the late list name already exists.", vbOKOnly
    End If

    ' row 4 is stringDate in date format
    If IsDate(myRunData(4, 1)) = False Then
        validateRunData = False
        MsgBox "Late date appears to have a typo.", vbOKOnly
    End If
    
    ' row 5 is numberDate in number format, and within this decade
    If IsNumeric(myRunData(5, 1)) = False Then
        validateRunData = False
        MsgBox "Late date appears to have a typo, or date conversion failed.", vbOKOnly
    ElseIf myRunData(5, 1) > 45000 Or myRunData(5, 1) < 40000 Then
        validateRunData = False
        MsgBox "Late date appears to have a typo, or date conversion failed.", vbOKOnly
    End If
    
    result = BottomOfFunction()

End Function
Function checkMyRunData() As Boolean
    
    result = topOfFunction("Showing RunData...")
    
    MsgBox "" & _
           myRunData(0, 0) & vbTab & vbTab & myRunData(0, 1) & vbCrLf & _
           myRunData(1, 0) & vbTab & myRunData(1, 1) & vbCrLf & _
           myRunData(2, 0) & vbTab & myRunData(2, 1) & vbCrLf & _
           myRunData(3, 0) & vbTab & myRunData(3, 1) & vbCrLf & _
           myRunData(4, 0) & vbTab & vbTab & myRunData(4, 1) & vbCrLf & _
           myRunData(5, 0) & vbTab & myRunData(5, 1) & vbCrLf & _
           myRunData(6, 0) & vbTab & myRunData(6, 1) & vbCrLf & _
           myRunData(7, 0) & vbTab & myRunData(7, 1) & vbCrLf & _
           myRunData(8, 0) & vbTab & myRunData(8, 1) & vbCrLf, _
       vbOKOnly
    checkMyRunData = True

    result = BottomOfFunction()

End Function

Function importParadoxExports() As Boolean

    result = topOfFunction("Importing 1XO Data...")
    ' import 1XO file
    Workbooks.Open fileName:=getRunData("lXOFileName")
    LastRow = Cells(65536, 1).End(xlUp).Row
    LastCol = Cells(1, 255).End(xlToLeft).Column
    Cells(1, 1).Resize(LastRow, LastCol).Select
    Selection.Copy
    Windows(2).Activate
    Sheets("1XO").Select
    Cells.Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
    Windows(2).Activate
    Application.CutCopyMode = False
    ActiveWorkbook.Close SaveChanges:=False
    
    result = topOfFunction("Importing Revision Data...")
    ' import Rev file
    Workbooks.Open fileName:=getRunData("RevFileName")
    LastRow = Cells(65536, 1).End(xlUp).Row
    LastCol = Cells(1, 255).End(xlToLeft).Column
    Cells(1, 1).Resize(LastRow, LastCol).Select
    Selection.Copy
    Windows(2).Activate
    Sheets("Revisions").Select
    Cells.Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
    Windows(2).Activate
    Application.CutCopyMode = False
    ActiveWorkbook.Close SaveChanges:=False

    result = BottomOfFunction()

End Function
Function ReduceSize2()

    'Delete non-null values from empty rows and columns in 1XO tab

    Dim FirstBlankColumn As String
    Dim FirstBlankColumnTemp As String
    Dim FirstBlankRow As Long
    Dim FirstBlankColumnNumber As Integer
    Dim FirstBlankColumnNumberTemp As String
    Dim LastRow As Long
    Dim LastCol As Integer

    On Error Resume Next ' only known error is a blank sheet having problem with .offset()
    
    LastRow = Cells(65536, 1).End(xlUp).Row
    If LastRow > 1 Then
        Range("A1").Select
        Selection.End(xlDown).Offset(1, 0).Select
        FirstBlankRow = ActiveCell.Row
    Else
        Range("A2").Select
        FirstBlankRow = ActiveCell.Row
    End If
    
    Range("A1").Select
    Selection.End(xlToRight).Offset(0, 1).Select
    FirstBlankColumnTemp = ActiveCell.Address
    FirstBlankColumn = Mid(FirstBlankColumnTemp, _
        InStr(FirstBlankColumnTemp, "$") + 1, _
        InStr(2, FirstBlankColumnTemp, "$") - 2)
    Rows(FirstBlankRow & ":" & FirstBlankRow).Select
    Range(Selection, Selection.End(xlDown)).Select
    Selection.Delete
    Columns(FirstBlankColumn & ":" & FirstBlankColumn).Select
    Range(Selection.End(xlToRight), Selection).Select
    Selection.Delete
    Range("A1").Select

End Function





Function labelImports() As Boolean

    result = topOfFunction("Identifying Data...")
    
    Dim tempText As String
    Dim tempName As String
    
    Sheets("1XO").Select
    Range("A1").Select
    For x = 1 To 40
        If Cells(1, x).Text <> "" Then
            Cells(1, x).Name = Cells(1, x).Text & "_1XO"
        End If
    Next x

    Sheets("Revisions").Select
    Range("A1").Select
    For x = 1 To 40
        If Cells(1, x).Text <> "" Then
            Cells(1, x).Name = Cells(1, x).Text & "_Rev"
        End If
    Next x
    
    result = BottomOfFunction()

End Function

Function formatImports() As Boolean
    
    'result = topOfFunction("Formatting Revision Data...")
    
    
    Dim tempLateDate As Date
    ' for debugging
    'tempLateDate = Now()
    tempLateDate = getRunData("stringDate")
    
    ' for finding first blank row during autofilter
    Dim firstrow As Long
    Dim r As Range
    Dim r1 As Range
    
    Sheets("Revisions").Select
    result = ReduceSize2()
    Rows("1:1").Select
    Selection.AutoFilter
    
    Range(Left(Range("InitiationDate_Rev").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1) & ":" & Left(Range("InitiationDate_Rev").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1)).Select
    Selection.NumberFormat = "[$-409]d-mmm-yy;@"
    
    Range(Left(Range("DueDate_Rev").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1) & ":" & Left(Range("DueDate_Rev").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1)).Select
    Selection.NumberFormat = "[$-409]d-mmm-yy;@"
    
    Range(Left(Range("CompleteDate_Rev").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1) & ":" & Left(Range("CompleteDate_Rev").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1)).Select
    Selection.NumberFormat = "[$-409]d-mmm-yy;@"
    
    Range(Left(Range("Totalpgs_Rev").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1) & ":" & Left(Range("Totalpgs_Rev").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1)).Select
    Selection.NumberFormat = "0"
    
    ' remove jobs that are not late
    Selection.AutoFilter Field:=12, Criteria1:=">" & tempLateDate
    Selection.AutoFilter Field:=15, Criteria1:="="
    
    With ActiveSheet.AutoFilter.Range
        Set r = .Offset(1, 0).Resize(.Rows.Count - 1, 1)
        On Error Resume Next 'next row throws error if no special cells are found
        Set r1 = r.SpecialCells(xlVisible)
        If Not r1 Is Nothing Then
            firstrow = r1.Areas(1).Row
        Else
            firstrow = 0
        End If
    End With
    If firstrow <> 0 Then
        Rows(firstrow & ":" & firstrow).Select
        Range(Selection, Selection.End(xlDown)).Select
        Selection.Delete
    End If
    ActiveSheet.ShowAllData
    
    ' remove completed jobs
    Selection.AutoFilter Field:=18, Criteria1:="Complete"
    
    With ActiveSheet.AutoFilter.Range
        Set r = .Offset(1, 0).Resize(.Rows.Count - 1, 1)
        On Error Resume Next 'next row throws error if no special cells are found
        Set r1 = r.SpecialCells(xlVisible)
        If Not r1 Is Nothing Then
            firstrow = r1.Areas(1).Row
        Else
            firstrow = 0
        End If
    End With
    If firstrow <> 0 Then
        Rows(firstrow & ":" & firstrow).Select
        Range(Selection, Selection.End(xlDown)).Select
        Selection.Delete
    End If
    ActiveSheet.ShowAllData
    

    Rows("1:1").Select
    Selection.Insert Shift:=xlDown
    Selection.Insert Shift:=xlDown
    Selection.Insert Shift:=xlDown
    
    Range("A1").FormulaR1C1 = "Total Pages"
    Range("A2").FormulaR1C1 = "Total Subjobs"
    Range("C1").FormulaR1C1 = "=SUBTOTAL(9,R[4]C[14]:R[998]C[14])" ' subtotal sum of all page numbers
    Range("C2").FormulaR1C1 = "=SUBTOTAL(3,R[3]C[1]:R[997]C[1])" ' subtotal count of all jobs
    
    Cells.EntireColumn.AutoFit
    With Range("T:X")
        .ColumnWidth = 50
        .WrapText = True
    End With
    
    Range("A5").Select
    ActiveWindow.FreezePanes = True

    Range("A1").Select

'##############
    
    result = topOfFunction("Formatting 1XO data...")
    
    Sheets("1XO").Select
    result = ReduceSize2()

    Rows("1:1").Select
    Selection.AutoFilter
    
    Range(Left(Range("MailDate_1XO").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1) & ":" & Left(Range("MailDate_1XO").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1)).Select
    Selection.NumberFormat = "[$-409]d-mmm-yy;@"
    
    Range(Left(Range("TaskDueDate_1XO").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1) & ":" & Left(Range("TaskDueDate_1XO").Address(RowAbsolute:=False, ColumnAbsolute:=False), 1)).Select
    Selection.NumberFormat = "[$-409]d-mmm-yy;@"
    
    ' remove jobs not due yet
    Selection.AutoFilter Field:=8, Criteria1:=">" & tempLateDate ' field # is column number for MailDate_1XO
    With ActiveSheet.AutoFilter.Range
        Set r = .Offset(1, 0).Resize(.Rows.Count - 1, 1)
        On Error Resume Next 'next row throws error if no special cells are found
        Set r1 = r.SpecialCells(xlVisible)
        If Not r1 Is Nothing Then
            firstrow = r1.Areas(1).Row
        Else
            firstrow = 0
        End If
    End With
    If firstrow <> 0 Then
        Rows(firstrow & ":" & firstrow).Select
        Range(Selection, Selection.End(xlDown)).Select
        Selection.Delete
    End If
    ActiveSheet.ShowAllData
    
    ' remove completed jobs
    Selection.AutoFilter Field:=12, Criteria1:="Complete" ' field # is column number for Stage_1XO
    With ActiveSheet.AutoFilter.Range
        Set r = .Offset(1, 0).Resize(.Rows.Count - 1, 1)
        On Error Resume Next 'next row throws error if no special cells are found
        Set r1 = r.SpecialCells(xlVisible)
        If Not r1 Is Nothing Then
            firstrow = r1.Areas(1).Row
        Else
            firstrow = 0
        End If
    End With
    If firstrow <> 0 Then
        Rows(firstrow & ":" & firstrow).Select
        Range(Selection, Selection.End(xlDown)).Select
        Selection.Delete
    End If
    ActiveSheet.ShowAllData
    
    
    ' remove jobs not scheduled yet
    Selection.AutoFilter Field:=8, Criteria1:="" ' field # is column number for MailDate_1XO
    With ActiveSheet.AutoFilter.Range
        Set r = .Offset(1, 0).Resize(.Rows.Count - 1, 1)
        On Error Resume Next 'next row throws error if no special cells are found
        Set r1 = r.SpecialCells(xlVisible)
        If Not r1 Is Nothing Then
            firstrow = r1.Areas(1).Row
        Else
            firstrow = 0
        End If
    End With
    If firstrow <> 0 Then
        Rows(firstrow & ":" & firstrow).Select
        Range(Selection, Selection.End(xlDown)).Select
        Selection.Delete
    End If
    ActiveSheet.ShowAllData

    ' remove jobs with customer
    Selection.AutoFilter Field:=12, Criteria1:="Customer" ' field # is column number for Stage_1XO
    With ActiveSheet.AutoFilter.Range
        Set r = .Offset(1, 0).Resize(.Rows.Count - 1, 1)
        On Error Resume Next 'next row throws error if no special cells are found
        Set r1 = r.SpecialCells(xlVisible)
        If Not r1 Is Nothing Then
            firstrow = r1.Areas(1).Row
        Else
            firstrow = 0
        End If
    End With
    If firstrow <> 0 Then
        Rows(firstrow & ":" & firstrow).Select
        Range(Selection, Selection.End(xlDown)).Select
        Selection.Delete
    End If
    ActiveSheet.ShowAllData

    ' remove jobs that should say customer, but don't
    Selection.AutoFilter Field:=12, Criteria1:="File Prep" ' field # is column number for Stage_1XO
    Selection.AutoFilter Field:=13, Criteria1:="" ' field # is column number for TaskDate_1XO
    With ActiveSheet.AutoFilter.Range
        Set r = .Offset(1, 0).Resize(.Rows.Count - 1, 1)
        On Error Resume Next 'next row throws error if no special cells are found
        Set r1 = r.SpecialCells(xlVisible)
        If Not r1 Is Nothing Then
            firstrow = r1.Areas(1).Row
        Else
            firstrow = 0
        End If
    End With
    If firstrow <> 0 Then
        Rows(firstrow & ":" & firstrow).Select
        Range(Selection, Selection.End(xlDown)).Select
        Selection.Delete
    End If
    ActiveSheet.ShowAllData

    Rows("1:1").Select
    Selection.Insert Shift:=xlDown
    Selection.Insert Shift:=xlDown
    Selection.Insert Shift:=xlDown

    Range("A1").FormulaR1C1 = "Total Pages"
    Range("A2").FormulaR1C1 = "Total Subjobs"
    Range("C1").FormulaR1C1 = "=SUBTOTAL(9,R[4]C[7]:R[998]C[7])" ' subtotal sum of all page numbers
    Range("C2").FormulaR1C1 = "=SUBTOTAL(3,R[3]C[0]:R[997]C[0])" ' subtotal count of all jobs

    Cells.EntireColumn.AutoFit
    With Range("V:X")
        .ColumnWidth = 50
        .WrapText = True
    End With

    Range("A5").Select
    ActiveWindow.FreezePanes = True

    Range("A1").Select

    result = BottomOfFunction()

End Function
Function buildOverview() As Boolean

    result = topOfFunction("Building Overview Sheet...")
    
    Sheets("Overview").Select

    Range("A1").Formula = "Late List"
    Range("A2").Formula = "Generated on"
    Range("A4").Formula = "1XO"
    Range("D4").Formula = "Revisions"
    Range("G4").Formula = "QMS Status"
    Range("A5,D5,G5").Formula = "Total Pages"
    Range("A6,D6,G6").Formula = "Total Subjobs"
    
    Range("A8,d8").Formula = "Pages in Proof Delivery"
    Range("A9,d9").Formula = "Subjobs in Proof Delivery"
    Range("A10,d10").Formula = "Pages in Proofreading"
    Range("A11,d11").Formula = "Subjobs in Proofreading"
    Range("A12,d12").Formula = "Pages in Typesetting"
    Range("A13,d13").Formula = "Subjobs in Typesetting"
    Range("A14").Formula = "Pages in Art"
    Range("A15").Formula = "Subjobs in Art"
    Range("A16").Formula = "Pages in Copy Editing"
    Range("A17").Formula = "Subjobs in Copy Editing"
    Range("A18").Formula = "Pages in Tables and Math"
    Range("A19").Formula = "Subjobs in Tables and Math"
    Range("A20,d16").Formula = "Pages in Pre-Page"
    Range("A21,d17").Formula = "Subjobs in Pre-Page"
    Range("A22").Formula = "Pages in Preprint"
    Range("A23").Formula = "Subjobs in Preprint"
    Range("A24").Formula = "Pages in File Prep XML"
    Range("A25").Formula = "Subjobs in File Prep XML"
    Range("A26").Formula = "Pages in File Prep"
    Range("A27").Formula = "Subjobs in File Prep"
    Range("A28").Formula = "Pages in PE Distribution"
    Range("A29").Formula = "Subjobs PE Distribution"
    Range("D14").Formula = "Pages in D&L Covers"
    Range("D15").Formula = "Subjobs in D&L Covers"
    Range("D18").Formula = "Pages in Revision Check In"
    Range("D19").Formula = "Subjobs in Revision Check In"
    Range("D20").Formula = "Pages in Online Pub"
    Range("D21").Formula = "Subjobs in Online Pub"
    Range("D22").Formula = "Pages in File Delivery"
    Range("D23").Formula = "Subjobs in File Delivery"
    Range("A30,D24").Formula = "Pages in Unknown"
    Range("A31,D25").Formula = "Subjobs in Unknown"
    
    Range("G8").Formula = "Pages Red"
    Range("G9").Formula = "Subjobs Red"
    Range("G10").Formula = "Pages Yellow"
    Range("G11").Formula = "Subjobs Yellow"
    Range("G12").Formula = "Pages Green"
    Range("G13").Formula = "Subjobs Green"
    Range("G14").Formula = "Pages Black"
    Range("G15").Formula = "Subjobs Black"
    
    'Set fonts for titles on Overview tab
    With Range("A1").Font
        .Name = "Arial"
        .Size = 18
    End With

    With Range("a4,d4,g4").Font
        .Name = "Arial"
        .Size = 14
        .Bold = True
    End With
    
    'Set box outlines on Overview tab
    Range("A5:B6,A8:B31,D5:E6,D8:E25,G5:H6,G8:H15").Select
    'Selection.Borders(xlDiagonalDown).LineStyle = xlNone
    'Selection.Borders(xlDiagonalUp).LineStyle = xlNone
    With Selection.Borders
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With

    'Set alternate row shading on Overview tab
    Range("A8:B9,A12:B13,A16:B17,A20:B21,A24:B25,A28:B29,D8:E9,D12:E13,D16:E17,D20:E21,D24:E25,G8:H9,G12:H13").Select
    With Selection.Interior
        .ColorIndex = 36
        .Pattern = xlSolid
        .PatternColorIndex = xlAutomatic
    End With

    Cells.EntireColumn.AutoFit
    Range("B:B,E:E,H:H").ColumnWidth = 20

    ' add explanatory comments to some headings
    Range("D2").FormulaR1C1 = "See the comments (red corner arrows) for description of terminology."
    
    If Range("A5").Comment Is Nothing Then
        Range("A5").AddComment
        Range("A5").Comment.Visible = False
        Range("A5").Comment.Text Text:="Page counts for 1XO are manuscipt pages (in Microsoft Word)."
    End If

    If Range("D5").Comment Is Nothing Then
        Range("D5").AddComment
        Range("D5").Comment.Visible = False
        Range("D5").Comment.Text Text:="Page counts for Revisions are typeset, printed pages."
    End If

    If Range("G5").Comment Is Nothing Then
        Range("G5").AddComment
        Range("G5").Comment.Visible = False
        Range("G5").Comment.Text Text:="Page counts for QMS status are a combination of 1XO manuscript pages and Revision typeset pages."
    End If

    result = BottomOfFunction()

End Function
Function generateNumbers()

    result = topOfFunction("Generating Numbers...")
    
    Range("B5").Formula = "=SUMPRODUCT('1XO'!J5:J999)" 'total pages 1XO
    Range("B6").Formula = "=COUNTA('1XO'!C5:C999)" ' Total Subjobs 1XO
    Range("b8").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""Proof Delivery""))" '1XO Pages in Proof Delivery
    Range("b9").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""Proof Delivery""))" '1XO Subjobs in Proof Delivery
    Range("b10").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""Proofreading""))" '1XO Pages in Proofreading
    Range("b11").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""Proofreading""))" '1XO Subjobs in Proofreading
    Range("b12").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""Typesetting""))" '1XO Pages in Typesetting
    Range("b13").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""Typesetting""))" '1XO Subjobs in Typesetting
    Range("b14").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""Art""))" '1XO Pages in Art
    Range("b15").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""Art""))" '1XO Subjobs in Art
    Range("b16").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""Copyedit""))" '1XO Pages in Copy Editing
    Range("b17").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""Copyedit""))" '1XO Subjobs in Copy Editing
    Range("b18").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""Tables/Math""))" '1XO Pages in Tables/Math
    Range("b19").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""Tables/Math""))" '1XO Subjobs in Tables/Math
    Range("b20").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""Pre-Page""))" '1XO Pages in Pre-Page
    Range("b21").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""Pre-Page""))" '1XO Subjobs in Pre-Page
    Range("b22").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""Preprint""))" '1XO Pages in Preprint
    Range("b23").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""Preprint""))" '1XO Subjobs in Preprint
    Range("b24").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""File Prep XML""))" '1XO Pages in File Prep XML
    Range("b25").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""File Prep XML""))" '1XO Subjobs in File Prep XML
    Range("b26").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""File Prep""))" '1XO Pages in File Prep
    Range("b27").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""File Prep""))" '1XO Subjobs in File Prep
    Range("b28").Formula = "=SUMPRODUCT(('1XO'!J5:J999)*('1XO'!L5:L999=""PE Distribution""))" '1XO Pages in PE Distribution
    Range("b29").Formula = "=SUMPRODUCT(('1XO'!C5:C999<>"""")*('1XO'!L5:L999=""PE Distribution""))" '1XO Subjobs in PE Distribution
    Range("b30").Formula = "=B5-(B8+B10+B12+B14+B16+B18+B20+B22+B24+B26+B28)" '1XO Pages in Unknown
    Range("b31").Formula = "=B6-(B9+B11+B13+B15+B17+B19+B21+B23+B25+B27+B29)" '1XO Subjobs in Unknown

    Range("E5").Formula = "=SUMPRODUCT(Revisions!Q5:Q999)" 'total pages Rev
    Range("E6").Formula = "=COUNTA(Revisions!D5:D999)" ' Total Subjobs Rev
    Range("E8").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!R5:R999=""Proof Delivery""))" ' Rev Pages in Proof Delivery
    Range("E9").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!R5:R999=""Proof Delivery""))" ' Rev Subjobs in Proof Delivery
    Range("E10").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!R5:R999=""Proofreading""))" ' Rev Pages in Proofreading
    Range("E11").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!R5:R999=""Proofreading""))" ' Rev Subjobs in Proofreading
    Range("E12").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!R5:R999=""Typesetting""))" ' Rev Pages in Typesetting
    Range("E13").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!R5:R999=""Typesetting""))" ' Rev Subjobs in Typesetting
    Range("E14").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!R5:R999=""D&L Cover""))" ' Rev Pages in D&L Covers
    Range("E15").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!R5:R999=""D&L Cover""))" ' Rev Subjobs in D&L Covers
    Range("E16").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!R5:R999=""Pre-Page""))" ' Rev Pages in Pre-Page
    Range("E17").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!R5:R999=""Pre-Page""))" ' Rev Subjobs in Pre-Page
    Range("E18").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!R5:R999=""rev checkin""))" ' Rev Pages in Revision Check In
    Range("E19").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!R5:R999=""rev checkin""))" ' Rev Subjobs in Revision Check In
    Range("E20").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!R5:R999=""Online Pub""))" ' Rev Pages in Online Pub
    Range("E21").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!R5:R999=""Online Pub""))" ' Rev Subjobs in Online Pub
    Range("E22").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!R5:R999=""File Delivery""))" ' Rev Pages in File Delivery
    Range("E23").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!R5:R999=""File Delivery""))" ' Rev Subjobs in File Delivery
    Range("E24").Formula = "=E5-(E8+E10+E12+E14+E16+E18+E20+E22)" ' Rev Pages in Unknown
    Range("E25").Formula = "=E6-(E9+E11+E13+E15+E17+E19+E21+E23)" ' Rev Subjobs in Unknown

    Range("H5").Formula = "=B5+E5" ' total pages QMS
    Range("H6").Formula = "=B6+E6" ' Total Subjobs QMS
    Range("H8").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!B5:B999=""Red""))+SUMPRODUCT(('1XO'!J5:J999)*('1XO'!B5:B999=""Red""))" ' Pages Red
    Range("H9").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!B5:B999=""Red""))+SUMPRODUCT(('1XO'!J5:J999<>"""")*('1XO'!B5:B999=""Red""))" ' Subjobs Red
    Range("H10").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!B5:B999=""Yellow""))+SUMPRODUCT(('1XO'!J5:J999)*('1XO'!B5:B999=""Yellow""))" ' Pages Yellow
    Range("H11").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!B5:B999=""Yellow""))+SUMPRODUCT(('1XO'!J5:J999<>"""")*('1XO'!B5:B999=""Yellow""))" ' Subjobs Yellow
    Range("H12").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!B5:B999=""Green""))+SUMPRODUCT(('1XO'!J5:J999)*('1XO'!B5:B999=""Green""))" ' Pages Green
    Range("H13").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!B5:B999=""Green""))+SUMPRODUCT(('1XO'!J5:J999<>"""")*('1XO'!B5:B999=""Green""))" ' Subjobs Green
    Range("H14").Formula = "=SUMPRODUCT((Revisions!Q5:Q999)*(Revisions!B5:B999=""Black""))+SUMPRODUCT(('1XO'!J5:J999)*('1XO'!B5:B999=""Black""))" ' Pages Black
    Range("H15").Formula = "=SUMPRODUCT((Revisions!Q5:Q999<>"""")*(Revisions!B5:B999=""Black""))+SUMPRODUCT(('1XO'!J5:J999<>"""")*('1XO'!B5:B999=""Black""))" ' Subjobs Black

    ' set the current date and time
    Range("B3").Formula = "=NOW()"
    Range("B3").Copy
    Range("B2").PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
    Application.CutCopyMode = False
    Range("B2").NumberFormat = "d-mmm-yy h:mm AM/PM"
    Range("B3").ClearContents
    
    Cells.Select
    Selection.Copy
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
    Application.CutCopyMode = False
    
    Range("A1").Select
    result = BottomOfFunction()

End Function

Function saveLateList() As Boolean

    result = topOfFunction("Saving...")
    
    ActiveWorkbook.SaveAs fileName:=getRunData("OutputFileName"), _
        FileFormat:=xlNormal, Password:="", WriteResPassword:="", _
        ReadOnlyRecommended:=False, CreateBackup:=False
    
    result = BottomOfFunction()

End Function
Function topOfFunction(Optional myStatusString As String) As Boolean
    
    Application.DisplayAlerts = False
    Application.ScreenUpdating = False
    
    If myStatusString <> "" Then
        If getRunData("myAutoMode") = False Then
            Application.StatusBar = myStatusString
        End If
    End If
    
    If getRunData("myDebugMode") = True Then
        Application.StatusBar = myStatusString
        Application.DisplayAlerts = True
        Application.ScreenUpdating = True
    End If
    
    DoEvents
    topOfFunction = True

End Function
Function BottomOfFunction() As Boolean
    
    
    '    Application.ScreenUpdating = True
    '    Application.DisplayAlerts = True
    '    Application.StatusBar = False
    
    DoEvents
    BottomOfFunction = True

End Function

Function prepareWorkbook()

Dim mySheetCount As Byte
mySheetCount = 3

    ' ensure there is only one workbook open to work with
    If Application.Workbooks.Count = 0 Then
        Application.Workbooks.Add
    ElseIf Application.Workbooks.Count = 1 And Left$(Application.Workbooks(1).Name, 9) = "PERSONAL." Then
        Application.Workbooks.Add
    ElseIf Application.Workbooks.Count > 1 Then
        result = setRunData("abort", "True")
    End If

' ensure the correct number of sheets
Do
    If Worksheets.Count < mySheetCount Then
        Sheets.Add
    ElseIf Worksheets.Count > mySheetCount Then
        Sheets(mySheetCount + 1).Delete
    End If
Loop Until Worksheets.Count = mySheetCount

' rename sheets in order to avoid duplicate name error messages
For s = 1 To mySheetCount
    Sheets(s).Name = "newSheet" & s
Next s

' rename the sheets correctly
Sheets(1).Name = "1XO"
Sheets(2).Name = "Revisions"
Sheets(3).Name = "Overview"

End Function

Function getRunData(myKey As String) As String

    
    
    'recives a keyword for the 0 column, and returns the matching string in the 1 column
    For i = LBound(myRunData) To UBound(myRunData)
        If myRunData(i, 0) = myKey Then
            getRunData = myRunData(i, 1)
            Exit For
        End If
    Next i

    

End Function

Function setRunData(myKey As String, myValue As String) As Boolean

    

    'recives a keyword for the 0 column, and inserts the value in the 1 column
    For i = LBound(myRunData) To UBound(myRunData)
        If myRunData(i, 0) = myKey Then
            setRunData = True
            myRunData(i, 1) = myValue
            Exit For
        End If
    Next i
    
    

End Function


Sub testLateListFunctions()

    Dim result As Variant
    
    
    
    result = getDefaultRunData()
    If result <> True Then
        MsgBox "Bad result returned from getDefaultRunData()", vbOKOnly
    End If
        
    result = validateRunData()
    If result <> True Then
        MsgBox "Bad result returned from validateRunData()", vbOKOnly
    End If

    result = checkMyRunData()
    If result <> True Then
        MsgBox "Bad result returned from checkMyRunData()", vbOKOnly
    End If

    result = getRunData("abort")
    If result <> True And result <> False Then
        MsgBox "Bad result returned from getRunData() for abort value", vbOKOnly
    End If
    
    result = getRunData("stringDate")
    If Not IsDate(result) Then
        MsgBox "Bad result returned from getRunData() for stringDate", vbOKOnly
    End If
    
    result = setRunData("myAutoMode", "False")
    If getRunData("myAutoMode") <> False Then
        MsgBox "Bad result returned from setRunData() for myAutoMode", vbOKOnly
    End If


End Sub
Function ConvertToLetter(iCol As Integer) As String
   Dim iAlpha As Integer
   Dim iRemainder As Integer
   iAlpha = Int(iCol / 27)
   iRemainder = iCol - (iAlpha * 26)
   If iAlpha > 0 Then
      ConvertToLetter = Chr(iAlpha + 64)
   End If
   If iRemainder > 0 Then
      ConvertToLetter = ConvertToLetter & Chr(iRemainder + 64)
   End If
End Function






