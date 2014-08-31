Attribute VB_Name = "Tools"
Option Compare Database
Option Explicit

Public Function outputHtmlLog()
    
    ' rewrote this for speed
    '
    ' saving directoy to outfile_network took over a minute.  Could not figure out why.
    ' saving to local folder then making a copy on network only takes a couple seconds.
    '
    ' JHenderson 23 July 2013
    '

    Dim outfile_local As String
    Dim outfile_network As String
    outfile_local = "\\mis4\CustomerServices\Core\Metric_Generation\out\reportingLog.htm"
    outfile_network = "\\mis4\CustomerServices\Core\Metric_Generation\out\webpage\reportingLog.htm"
   
   ' if files outfiles already exist, delete them
   If (Dir(outfile_local) <> "") Then ' checking if the file exists does not return empty string
      SetAttr outfile_local, vbNormal
      Kill outfile_local
   End If

   If (Dir(outfile_network) <> "") Then ' checking if the file exists does not return empty string
      SetAttr outfile_network, vbNormal
      Kill outfile_network
   End If

   ' output the html files to local folder
   'DoCmd.OutputTo acOutputTable, "logs", acFormatHTML, outfile_local
   'DoCmd.OutputTo acOutputTable, "archivedLogs", acFormatHTML, outfile_local
   DoCmd.OutputTo acOutputTable, "errorLogs", acFormatHTML, outfile_local
   
   ' make network copy in obtuse fashion...
   Name outfile_local As outfile_network ' if file already exists, this will throw an error

End Function



Public Function old_outputHtmlLog()
    
    Dim outfile As String
    'outfile = "\\mis4\CustomerServices\Core\Metric_Generation\out\test\log_test.htm"
    outfile = "\\mis6\Inetpub\AllenPressNet\AP-Projects\CurrentReports\reportingLog.htm"
   
   If (Dir(outfile) <> "") Then ' checking if the file exists does not return empty string
      SetAttr outfile, vbNormal
      Kill outfile
   End If


    'DoCmd.OutputTo acOutputTable, "logs", acFormatHTML, outfile
    'DoCmd.OutputTo acOutputTable, "archivedLogs", acFormatHTML, outfile
    DoCmd.OutputTo acOutputTable, "errorLogs", acFormatHTML, outfile

End Function

