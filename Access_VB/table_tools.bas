Option Compare Database
Option Explicit

' since leaving linked tables open locks things up and hogs bandwidth
' I use this to make local copies of all linked tables

Function ImportLinkedTables()

    Dim MyDB As DAO.Database
    Set MyDB = CurrentDb

    Dim tdf As DAO.TableDef
    Set tdf = Nothing

    Dim tempSQL  As String
    tempSQL = ""

    On Error Resume Next
    DoCmd.Hourglass True
    DoCmd.SetWarnings False

    ' Loop through all tables in database.
    For Each tdf In MyDB.TableDefs
    'MsgBox tdf.Name, vbOKOnly

        ' only act on linked tables, avoid temp tables
        If Len(tdf.Connect) > 0 And Left(tdf.Name, 1) <> "~" Then

            ' looks like "SELECT     payroll.*      INTO local_payroll          FROM payroll;"
            tempSQL = "SELECT " & tdf.Name & ".* INTO local_" & tdf.Name & " FROM " & tdf.Name & ";"
            DoCmd.RunSQL tempSQL
            tempSQL = ""

        Else

            ' ignore the rest of the tables

        End If

    Next tdf

    DoCmd.SetWarnings True
    DoCmd.Hourglass False

End Function



Function ActiveDirectoryPeople()hang glider cape youtubed

' testing out grabbing OUs from active directory and writing them to Access tables

    '*****************************************
    '*Connects To AD and sets search criteria*
    '*****************************************
    'On Error Resume Next
    Dim dbs As Database
    Set dbs = CurrentDb

    Dim rs As ADODB.Recordset
    Dim strSql As String
    Const ADS_SCOPE_SUBTREE = 2

    Dim objConnection As Object
    Set objConnection = CreateObject("ADODB.Connection")
    Dim objCommand As Object
    Set objCommand = CreateObject("ADODB.Command")
    objConnection.Provider = "ADsDSOObject"
    objConnection.Open "Active Directory Provider"
    Set objCommand.ActiveConnection = objConnection
    objCommand.Properties("Page Size") = 1000
    objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE

    Dim attributeList(0 To 35) As String ' array for list of active directory attributes
    attributeList(0) = "distinguishedName"
    attributeList(1) = "canonicalName"
    attributeList(2) = "cn"
    attributeList(3) = "name"
    attributeList(4) = "displayName"
    attributeList(5) = "displayNamePrintable"
    attributeList(6) = "adminDescription"
    attributeList(7) = "adminDisplayName"
    attributeList(8) = "ADsPath"
    attributeList(9) = "objectClass"
    attributeList(10) = "createTimeStamp"
    attributeList(11) = "groupType"
    attributeList(12) = "info"
    attributeList(13) = "isDeleted"
    attributeList(14) = "legacyExchangeDN"
    attributeList(15) = "mail"
    attributeList(16) = "managedBy"
    attributeList(17) = "member"
    attributeList(18) = "memberOf"
    attributeList(19) = "modifyTimeStamp"
    attributeList(20) = "msSFU30Name"
    attributeList(21) = "msSFU30NisDomain"
    attributeList(22) = "msSFU30PosixMember"
    attributeList(23) = "nTSecurityDescriptor"
    attributeList(24) = "objectCategory"
    attributeList(25) = "objectGUID"
    attributeList(26) = "objectSid"
    attributeList(27) = "primaryGroupToken"
    attributeList(28) = "proxyAddresses"
    attributeList(29) = "sAMAccountName"
    attributeList(30) = "telephoneNumber"
    attributeList(31) = "textEncodedORAddress"
    attributeList(32) = "uSNChanged"
    attributeList(33) = "uSNCreated"
    attributeList(34) = "whenChanged"
    attributeList(35) = "whenCreated"

    Dim counter As Integer

' build the table
    ' if table exists, drop it
    If Not IsNull(DLookup("Name", "MSysObjects", "Name='AD_OU_APEmployees' And Type In (1,4,5,6)")) Then
     dbs.Execute "DROP TABLE AD_OU_APEmployees;"
    End If
    ' and make a new one
    dbs.Execute "CREATE TABLE AD_OU_APEmployees;"
    For counter = 0 To UBound(attributeList)
       ' for each field, add a column to the table
       dbs.Execute "ALTER TABLE AD_OU_APEmployees ADD COLUMN [" & attributeList(counter) & "] MEMO;"
    Next
    ' change the first column back to string, so it can be used in joins
    dbs.Execute "ALTER TABLE AD_OU_APEmployees ALTER COLUMN [" & attributeList(0) & "] CHAR;"

' query for the data
    For counter = 0 To UBound(attributeList)



        '**********************************************************************
        '*SQL statement on what OU to search and to look for User Objects ONLY*
        '**********************************************************************
        'objCommand.CommandText = _
        '"SELECT " & attributeList(0) & ", " & attributeList(counter) & " " & _
        '"FROM 'LDAP://OU=Allen Press Security Groups,DC=allenpress,DC=net' " & _
        '"WHERE objectClass='Group'"

        objCommand.CommandText = _
        "SELECT " & attributeList(0) & ", " & attributeList(counter) & " " & _
        "FROM 'LDAP://OU=Allen Press Employees,DC=allenpress,DC=net' " '& _
        '"WHERE objectClass='Group'"

        Dim outString As String
        Dim temp0
        Dim temp1

        Dim objrecordset As Object
        Set objrecordset = objCommand.Execute
        With objrecordset
        .MoveFirst
        Do While Not .EOF

            If IsNull(.Fields(0).Value) = True Then
            temp0 = ""
            ElseIf IsArray(.Fields(0).Value) = True And initializedArray(.Fields(0).Value) = False Then
            temp0 = ""
            ElseIf IsArray(.Fields(0).Value) = True Then
            temp0 = Join(.Fields(0).Value, vbCrLf) & ""
            Else
            'On Error GoTo temp0_blank
            On Error Resume Next
            temp0 = .Fields(0).Value
            End If
temp0_blank:
            If Len(temp0) < 1 Then
            temp0 = ""
            End If


            If IsNull(.Fields(1).Value) = True Then
            temp1 = ""
            ElseIf IsArray(.Fields(1).Value) = True And initializedArray(.Fields(1).Value) = False Then
            temp1 = ""
            ElseIf IsArray(.Fields(1).Value) = True Then
            temp1 = Join(.Fields(1).Value, vbCrLf) & ""
            Else
            On Error Resume Next
            temp1 = .Fields(1).Value
            End If
temp1_blank:
            If Len(temp1) < 1 Then
            temp1 = ""
            End If



            outString = _
                .Fields(0).Name & ": " & temp0 & "" & vbCrLf & vbCrLf & _
                .Fields(1).Name & ": " & temp1 & "" & vbCrLf & vbCrLf

             If counter = 0 Then
               dbs.Execute "INSERT INTO AD_OU_APEmployees (" & .Fields(1).Name & ") VALUES ('" & temp1 & "');"
             Else
               dbs.Execute "UPDATE AD_OU_APEmployees SET " & .Fields(0).Name & " = '" & temp0 & "' WHERE " & .Fields(1).Name & " = '" & temp1 & "';"
             End If

            'MsgBox outString, vbOKOnly
            temp0 = ""
            temp1 = ""
            .MoveNext
        Loop
        End With

        objrecordset.Close
        Set objrecordset = Nothing
    Next

End Function
