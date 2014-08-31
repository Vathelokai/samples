Attribute VB_Name = "aLogger"
Option Compare Database
Option Explicit

Public Function makeLogs(whereAt As String, whoCalled As String, eventType As String, detailLevel As String, Optional errNumber As Variant, Optional errDesc As Variant, Optional comment As String)
On Error GoTo metaErrorHandler
makeLogs = False
    
    ' ### notes ###
    ' could be re-done with ADODB connections in vba, but it requires libraries in all DB and is slower due to repeated open/close operations.
    ' the native handler (linked table) uses the same stuff in the background but seems to work a little better.
    '
    ' alternately, could keep local db logs and move them to main log on schedule or by trigger.
    ' would work alright, but does not seem necessary at this time.
    '
    ' may want to add data validation later.
    '
    ' jhenderson 14 feb 2013
    
    ' ### details ####
    ' this function returns a boolean
    ' this assumes the currentDB has a linked table to the _logs DB
    ' see test_makeLogs() for examples
    '
    ' excpected usage...
    '    dim makeLogResult as boolean
    '    makeLogResult = makeLogs("database_name", "macro_name", "eventType", "detailLevel", Err.Number, Err.Description, "some comments")
    '    makeLogResult = makeLogs("database_name", "macro_name", "eventType", "detailLevel", , , "some comments")
    '    makeLogResult = makeLogs("database_name", "macro_name", "eventType", "detailLevel")
    '
    ' data handed to this function should look like...
    '    whereAt (string name of database), required
    '    whoCalled (string name of macro), required
    '    eventType (string from list: {start|stop|interuption|error}), required
    '       start: subroutine or function is starting
    '       stop: subroutine or function ended successfully
    '       interuption: error which did not end process
    '       crash: error which ended process
    '    detailLevel (string from list: {info|debug|trace|alert|note}), required
    '       info: general info, what ran when
    '       debug: some details, what functions were called, what they returned
    '       trace: step by step details
    '       note: ad hoc space for anyone to add to logs, or enter logs manually
    '    errNumber (null or equal to Err.Number), optional
    '    errDescription (null or equal to Err.Desc), optional
    '    comments (null or any string; uses memo datatype)
    '
    ' db and macro names are passed as string parameters due to VBA lack of stack tracing and error handling vagueness.
    ' the values of the err objects components are passed to avoid overwrite of values in the err object.
    '
    '
    
    
    
    '### connect to log table ###
    Dim logTable As Recordset
    Set logTable = CurrentDb.OpenRecordset("logs") ' this is a linked table
    
    '### write entry on table ###
    With logTable
        .AddNew ' make record that looks like...
            
            ' default fields (for use in later queries)
            !Ordering = 100
            !timeStamp = Now()
            !whoInitiated = (Environ$("Username")) & " as " & Application.CurrentUser
            
            ' required fields
            !whereAt = whereAt
            !whoCalled = whoCalled
            !eventType = eventType
            !detailLevel = detailLevel
            
            ' optional fields
            If IsMissing(errNumber) = True Or IsNull(errNumber) = True Then
                !errorNumber = Null
            Else
                !errorNumber = errNumber
            End If
            
            If IsMissing(errDesc) = True Or IsNull(errDesc) = True Then
                !errorDescription = Null
            Else
                !errorDescription = errDesc
            End If
            
            If IsMissing(comment) = True Or IsNull(comment) = True Then
                !comment = Null
            Else
                !comment = comment
            End If
            
        .Update ' this appends the record
    End With
    
    '### clean up and exit ###
    logTable.Close
    Set logTable = Nothing
    makeLogs = True
    Exit Function

metaErrorHandler:
    
    With logTable
        .AddNew ' make record that looks like...
            !Ordering = 100
            !timeStamp = Now()
            !whoInitiated = (Environ$("Username")) & " as " & Application.CurrentUser
            !whereAt = "_schedule_control"
            !whoCalled = "makeLogs()"
            !eventType = "crash"
            !detailLevel = "debug"
            !errorNumber = Err.Number
            !errorDescription = Err.Description
            !comment = "logger has had an internal crash.  ending logger.  returning to calling function."
        .Update ' this appends the record
    End With

    logTable.Close
    Set logTable = Nothing
    makeLogs = False
    Exit Function


End Function

