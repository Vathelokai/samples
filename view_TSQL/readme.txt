This SQL View was created for MS SQL Server Manager 2008R2.

Reports were needed showing duplication of customers within the region segments, or duplication of employment status.  This large view makes use of derived tables to analyze the customer list and UNIONs the results into a single set which is fed to a report generator.  Specific status details are in the [myReason] fields.
