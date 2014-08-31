Attribute VB_Name = "Tests"
Option Compare Database
Option Explicit

Function whoIsLoggedIn()
    MsgBox "Logged in:  " & (Environ$("Username")) & " as " & Application.CurrentUser, vbOKOnly
End Function

Public Function testingHtmlLog()
    
    
    DoCmd.OutputTo acOutputTable, "logs", acFormatHTML, "\\mis4\CustomerServices\Core\Metric_Generation\out\test\log_test.htm", , "\\mis4\CustomerServices\Core\Metric_Generation\_logTemplate.html"
    'DoCmd.OutputTo acOutputTable, "logs", acFormatHTML, "\\mis6\Inetpub\AllenPressNet\AP-Projects\CurrentReports\reportingLog.htm"

End Function


Public Function test_makeLogs()
' see makeLogs() for details
test_makeLogs = False
    
    ' setup err handler
    Dim makeLogResult As Boolean
    On Error GoTo errorHandler
    
    ' log start of function
    makeLogResult = makeLogs("_schedule_control", "test_makeLogs()", "start", "info", Err.Number, Err.Description, "starting function")
    
    ' try data type error
    Dim test1 As Integer
    test1 = "abc"
    
    ' try divide by zero error
    Dim test2 As Integer
    test2 = 9 / 0
    
    ' log end of function (error handler should prevent reaching this)
    makeLogResult = makeLogs("_schedule_control", "test_makeLogs()", "end", "info", Err.Number, Err.Description, "ending function")
    test_makeLogs = True
    Exit Function
errorHandler:
    
    Select Case Err.Number
        Case 13 ' data type mismatch, continue
            makeLogResult = makeLogs("_schedule_control", "test_makeLogs()", "interuption", "debug", Err.Number, Err.Description, "moved to err handler, retrying")
            Err.Clear
            Resume Next
        Case Else ' all other errors, end function
            makeLogResult = makeLogs("_schedule_control", "test_makeLogs()", "error", "debug", Err.Number, Err.Description, "moved to err handler, quitting")
            Exit Function
    End Select
    
End Function



