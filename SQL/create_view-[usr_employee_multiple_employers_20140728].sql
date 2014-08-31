USE [NACS]
GO

/****** Object:  View [dbo].[usr_employee_multiple_employers_20140728]    Script Date: 08/06/2014 11:26:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* usr_employee_multiple_employers_20140721
 details for employees connected to multiple segments*/
CREATE VIEW [dbo].[usr_employee_multiple_employers_20140728]
AS
SELECT     TOP (100) PERCENT app_org.ORG_ID, app_org.ORG_NAME, seg_multiple.myReason AS DUPLICATION_TYPE, 
                      employer.MASTER_CUSTOMER_ID AS EMPLOYER_CUSTOMER_ID, employer.LABEL_NAME AS EMPLOYER_LABEL_NAME, 
                      CASE WHEN employer_order_master.order_no IS NULL AND employer.MASTER_CUSTOMER_ID NOT IN
                          (SELECT     temp_om.BILL_MASTER_CUSTOMER_ID
                            FROM          order_master temp_om
                            WHERE      temp_om.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID) THEN 'None' WHEN (isnull(employer_order_detail.CYCLE_BEGIN_DATE, 
                      dateadd(day, - 1, SYSDATETIME())) <= SYSDATETIME() AND isnull(employer_order_detail.CYCLE_END_DATE, dateadd(day, 1, SYSDATETIME())) >= SYSDATETIME()) 
                      AND employer.MASTER_CUSTOMER_ID IN
                          (SELECT     temp_om.BILL_MASTER_CUSTOMER_ID
                            FROM          order_master temp_om
                            WHERE      temp_om.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID AND temp_om.ORDER_NO <> employer_order_master.order_no) 
                      THEN 'Renew' WHEN (isnull(employer_order_detail.CYCLE_BEGIN_DATE, dateadd(day, - 1, SYSDATETIME())) <= SYSDATETIME() AND 
                      isnull(employer_order_detail.CYCLE_END_DATE, dateadd(day, 1, SYSDATETIME())) >= SYSDATETIME()) AND employer.MASTER_CUSTOMER_ID NOT IN
                          (SELECT     temp_om.BILL_MASTER_CUSTOMER_ID
                            FROM          order_master temp_om
                            WHERE      temp_om.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID AND temp_om.ORDER_NO <> employer_order_master.order_no) 
                      THEN 'New' WHEN NOT (isnull(employer_order_detail.CYCLE_BEGIN_DATE, dateadd(day, - 1, SYSDATETIME())) <= SYSDATETIME() AND 
                      isnull(employer_order_detail.CYCLE_END_DATE, dateadd(day, 1, SYSDATETIME())) >= SYSDATETIME()) 
                      THEN 'Lapsed' ELSE 'Unknown' END AS EMPLOYER_ORDER_STATUS, ISNULL(seg_control.WEB_SEGMENT_CONTROL_FLAG, 'N') AS PRIMARY_AFFILIATE, 
                      employee.MASTER_CUSTOMER_ID AS EMPLOYEE_CUSTOMER_ID, employee.LABEL_NAME AS EMPLOYEE_LABEL_NAME, 
                      CASE WHEN employee_order_master.order_no IS NULL THEN 'None' WHEN (isnull(employee_order_detail.CYCLE_BEGIN_DATE, dateadd(day, - 1, SYSDATETIME())) 
                      <= SYSDATETIME() AND isnull(employee_order_detail.CYCLE_END_DATE, dateadd(day, 1, SYSDATETIME())) >= SYSDATETIME()) AND 
                      employee.MASTER_CUSTOMER_ID IN
                          (SELECT     temp_om.SHIP_MASTER_CUSTOMER_ID
                            FROM          order_master temp_om
                            WHERE      temp_om.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID AND temp_om.ORDER_NO <> employee_order_master.order_no) 
                      THEN 'Renew' WHEN (isnull(employee_order_detail.CYCLE_BEGIN_DATE, dateadd(day, - 1, SYSDATETIME())) <= SYSDATETIME() AND 
                      isnull(employee_order_detail.CYCLE_END_DATE, dateadd(day, 1, SYSDATETIME())) >= SYSDATETIME()) AND employee.MASTER_CUSTOMER_ID NOT IN
                          (SELECT     temp_om.SHIP_MASTER_CUSTOMER_ID
                            FROM          order_master temp_om
                            WHERE      temp_om.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID AND temp_om.ORDER_NO <> employee_order_master.order_no) 
                      THEN 'New' WHEN NOT (isnull(employee_order_detail.CYCLE_BEGIN_DATE, dateadd(day, - 1, SYSDATETIME())) <= SYSDATETIME() AND 
                      isnull(employee_order_detail.CYCLE_END_DATE, dateadd(day, 1, SYSDATETIME())) >= SYSDATETIME()) 
                      THEN 'Lapsed' ELSE 'Unknown' END AS EMPLOYEE_ORDER_STATUS_WITH_EMPLOYER, employee.PRIMARY_JOB_TITLE AS EMPLOYEE_PRIMARY_JOB_TITLE, 
                      employee.PRIMARY_EMAIL_ADDRESS AS EMPLOYEE_PRIMARY_EMAIL_ADDRESS, 
                      employee.PUBLISH_PRIMARY_EMAIL_FLAG AS EMPLOYEE_PUBLISH_PRIMARY_EMAIL_FLAG, employee_address.ADDRESS_1 AS EMPLOYEE_ADDRESS_1, 
                      employee_address.ADDRESS_2 AS EMPLOYEE_ADDRESS_2, employee_address.ADDRESS_3 AS EMPLOYEE_ADDRESS_3, 
                      employee_address.ADDRESS_4 AS EMPLOYEE_ADDRESS_4, employee_address.CITY AS EMPLOYEE_CITY, employee_address.STATE AS EMPLOYEE_STATE, 
                      employee_address.POSTAL_CODE AS EMPLOYEE_POSTAL_CODE, employee_address.COUNTRY_CODE AS EMPLOYEE_COUNTRY_CODE, 
                      employee_address.COUNTRY_DESCR AS EMPLOYEE_COUNTRY_DESCR, employee_address.ADDRESS_STATUS_CODE AS EMPLOYEE_ADDRESS_STATUS_CODE,
                          (SELECT     TOP (1) od.CYCLE_BEGIN_DATE
                            FROM          dbo.ORDER_MASTER AS om INNER JOIN
                                                   dbo.ORDER_DETAIL AS od ON om.ORDER_NO = od.ORDER_NO
                            WHERE      (om.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID) AND (om.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID)
                            ORDER BY od.CYCLE_BEGIN_DATE DESC) AS MOST_RECENT_CYCLE_BEGIN_DATE,
                          (SELECT     TOP (1) od.CYCLE_END_DATE
                            FROM          dbo.ORDER_MASTER AS om INNER JOIN
                                                   dbo.ORDER_DETAIL AS od ON om.ORDER_NO = od.ORDER_NO
                            WHERE      (om.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID) AND (om.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID)
                            ORDER BY od.CYCLE_END_DATE DESC) AS MOST_RECENT_CYCLE_END_DATE,
                          (SELECT     TOP (1) od.INVOICE_DATE
                            FROM          dbo.ORDER_MASTER AS om INNER JOIN
                                                   dbo.ORDER_DETAIL AS od ON om.ORDER_NO = od.ORDER_NO
                            WHERE      (om.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID) AND (om.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID)
                            ORDER BY od.INVOICE_DATE DESC) AS MOST_RECENT_INVOICE_DATE
FROM         (SELECT DISTINCT 
                                              dbo.CUS_SEGMENT_MEMBER.MASTER_CUSTOMER_ID AS EMPLOYEE_ID, dbo.CUS_SEGMENT_MEMBER.SEGMENT_QUALIFIER1 AS EMPLOYER_ID, 
                                              test.myReason
                       FROM          (SELECT     EMPLOYEE_ID, EMPLOYEE_NAME, COUNT(ORG_ID) AS myCount, 'Member Multiple Segments' AS myReason
                                               FROM          (SELECT DISTINCT 
                                                                                              employer.ORG_ID, employee.MASTER_CUSTOMER_ID AS EMPLOYEE_ID, employee.LABEL_NAME AS EMPLOYEE_NAME, 
                                                                                              employer.MASTER_CUSTOMER_ID AS EMPLOYER_ID, employer.LABEL_NAME AS EMPLOYER_NAME
                                                                       FROM          dbo.CUS_SEGMENT_MEMBER AS seg_member INNER JOIN
                                                                                              dbo.CUSTOMER AS employer ON employer.MASTER_CUSTOMER_ID = seg_member.SEGMENT_QUALIFIER1 INNER JOIN
                                                                                              dbo.CUSTOMER AS employee ON employee.MASTER_CUSTOMER_ID = seg_member.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                                                                                              dbo.ORDER_MASTER ON dbo.ORDER_MASTER.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID AND 
                                                                                              dbo.ORDER_MASTER.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                                                                                              dbo.ORDER_DETAIL ON dbo.ORDER_MASTER.ORDER_NO = dbo.ORDER_DETAIL.ORDER_NO
                                                                       WHERE      (seg_member.SEGMENT_RULE_CODE = 'EMPLOYEE') AND (ISNULL(dbo.ORDER_DETAIL.CYCLE_BEGIN_DATE, DATEADD(day, - 1, 
                                                                                              SYSDATETIME())) <= SYSDATETIME()) AND (ISNULL(dbo.ORDER_DETAIL.CYCLE_END_DATE, DATEADD(day, 1, SYSDATETIME())) 
                                                                                              >= SYSDATETIME())) AS segment_employee_employer
                                               GROUP BY EMPLOYEE_ID, EMPLOYEE_NAME
                                               HAVING      (COUNT(ORG_ID) > 1)) AS test INNER JOIN
                                              dbo.CUS_SEGMENT_MEMBER ON test.EMPLOYEE_ID = dbo.CUS_SEGMENT_MEMBER.MASTER_CUSTOMER_ID
                       WHERE      (dbo.CUS_SEGMENT_MEMBER.SEGMENT_QUALIFIER1 <> 'NACS') AND (dbo.CUS_SEGMENT_MEMBER.SEGMENT_QUALIFIER1 IS NOT NULL)
                       UNION
                       SELECT DISTINCT 
                                             CUS_RELATIONSHIP_3.MASTER_CUSTOMER_ID AS EMPLOYEE_ID, CUS_RELATIONSHIP_3.RELATED_MASTER_CUSTOMER_ID AS EMPLOYER_ID, 
                                             test.myReason
                       FROM         (SELECT     employer.ORG_ID, employee.MASTER_CUSTOMER_ID AS EMPLOYEE_ID, employee.LABEL_NAME AS EMPLOYEE_NAME, 
                                                                     employer.MASTER_CUSTOMER_ID AS EMPLOYER_ID, employer.LABEL_NAME AS EMPLOYER_NAME, 
                                                                     'Employed Multiple Times by One Company' AS myReason, COUNT(employee.ORG_UNIT_ID) AS myCount
                                              FROM          dbo.CUS_RELATIONSHIP INNER JOIN
                                                                     dbo.CUSTOMER AS employer ON employer.MASTER_CUSTOMER_ID = dbo.CUS_RELATIONSHIP.RELATED_MASTER_CUSTOMER_ID INNER JOIN
                                                                     dbo.CUSTOMER AS employee ON employee.MASTER_CUSTOMER_ID = dbo.CUS_RELATIONSHIP.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                                                                     dbo.ORDER_MASTER AS ORDER_MASTER_7 ON ORDER_MASTER_7.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID AND 
                                                                     ORDER_MASTER_7.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                                                                     dbo.ORDER_DETAIL AS ORDER_DETAIL_7 ON ORDER_MASTER_7.ORDER_NO = ORDER_DETAIL_7.ORDER_NO
                                              WHERE      (dbo.CUS_RELATIONSHIP.RELATIONSHIP_CODE = 'EMPLOYEE') AND (ISNULL(dbo.CUS_RELATIONSHIP.BEGIN_DATE, DATEADD(day, - 1, 
                                                                     SYSDATETIME())) <= SYSDATETIME()) AND (ISNULL(dbo.CUS_RELATIONSHIP.END_DATE, DATEADD(day, 1, SYSDATETIME())) >= SYSDATETIME())
                                                                      AND (ORDER_MASTER_7.ORDER_STATUS_CODE <> 'C' OR
                                                                     ORDER_MASTER_7.ORDER_STATUS_CODE IS NULL) AND (ISNULL(ORDER_DETAIL_7.CYCLE_BEGIN_DATE, DATEADD(day, - 1, 
                                                                     SYSDATETIME())) <= SYSDATETIME()) AND (ISNULL(ORDER_DETAIL_7.CYCLE_END_DATE, DATEADD(day, 1, SYSDATETIME())) 
                                                                     >= SYSDATETIME())
                                              GROUP BY employer.ORG_ID, employee.MASTER_CUSTOMER_ID, employee.LABEL_NAME, employer.MASTER_CUSTOMER_ID, 
                                                                     employer.LABEL_NAME
                                              HAVING      (COUNT(employee.ORG_UNIT_ID) > 1)) AS test INNER JOIN
                                             dbo.CUS_RELATIONSHIP AS CUS_RELATIONSHIP_3 ON test.EMPLOYEE_ID = CUS_RELATIONSHIP_3.MASTER_CUSTOMER_ID
                       UNION
                       SELECT DISTINCT 
                                             dbo.CUS_SEGMENT_CONTROL.MASTER_CUSTOMER_ID AS EMPLOYEE_ID, dbo.CUS_SEGMENT_CONTROL.SEGMENT_QUALIFIER1 AS EMPLOYER_ID, 
                                             test.myReason
                       FROM         (SELECT     EMPLOYEE_ID, EMPLOYEE_NAME, COUNT(ORG_ID) AS myCount, 'Controlls Multiple Segments' AS myReason
                                              FROM          (SELECT DISTINCT 
                                                                                             employer.ORG_ID, employee.MASTER_CUSTOMER_ID AS EMPLOYEE_ID, employee.LABEL_NAME AS EMPLOYEE_NAME, 
                                                                                             employer.MASTER_CUSTOMER_ID AS EMPLOYER_ID, employer.LABEL_NAME AS EMPLOYER_NAME
                                                                      FROM          dbo.CUS_SEGMENT_CONTROL AS seg_control INNER JOIN
                                                                                             dbo.CUSTOMER AS employer ON employer.MASTER_CUSTOMER_ID = seg_control.SEGMENT_QUALIFIER1 INNER JOIN
                                                                                             dbo.CUSTOMER AS employee ON employee.MASTER_CUSTOMER_ID = seg_control.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                                                                                             dbo.ORDER_MASTER AS ORDER_MASTER_6 ON 
                                                                                             ORDER_MASTER_6.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID AND 
                                                                                             ORDER_MASTER_6.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                                                                                             dbo.ORDER_DETAIL AS ORDER_DETAIL_6 ON ORDER_MASTER_6.ORDER_NO = ORDER_DETAIL_6.ORDER_NO
                                                                      WHERE      (seg_control.SEGMENT_RULE_CODE = 'EMPLOYEE') AND (ISNULL(ORDER_DETAIL_6.CYCLE_BEGIN_DATE, DATEADD(day, - 1, 
                                                                                             SYSDATETIME())) <= SYSDATETIME()) AND (ISNULL(ORDER_DETAIL_6.CYCLE_END_DATE, DATEADD(day, 1, SYSDATETIME())) 
                                                                                             >= SYSDATETIME())) AS segment_employee_control
                                              GROUP BY EMPLOYEE_ID, EMPLOYEE_NAME
                                              HAVING      (COUNT(ORG_ID) > 1)) AS test INNER JOIN
                                             dbo.CUS_SEGMENT_CONTROL ON test.EMPLOYEE_ID = dbo.CUS_SEGMENT_CONTROL.MASTER_CUSTOMER_ID
                       UNION
                       SELECT DISTINCT 
                                             CUS_RELATIONSHIP_1.MASTER_CUSTOMER_ID AS EMPLOYEE_ID, CUS_RELATIONSHIP_1.RELATED_MASTER_CUSTOMER_ID AS EMPLOYER_ID, 
                                             test.myReason
                       FROM         (SELECT     EMPLOYEE_ID, EMPLOYEE_NAME, COUNT(ORG_ID) AS myCount, 'Employed by Multiple Segments' AS myReason
                                              FROM          (SELECT DISTINCT 
                                                                                             employer.ORG_ID, employee.MASTER_CUSTOMER_ID AS EMPLOYEE_ID, employee.LABEL_NAME AS EMPLOYEE_NAME, 
                                                                                             employer.MASTER_CUSTOMER_ID AS EMPLOYER_ID, employer.LABEL_NAME AS EMPLOYER_NAME
                                                                      FROM          dbo.CUS_RELATIONSHIP AS CUS_RELATIONSHIP_2 INNER JOIN
                                                                                             dbo.CUSTOMER AS employer ON 
                                                                                             employer.MASTER_CUSTOMER_ID = CUS_RELATIONSHIP_2.RELATED_MASTER_CUSTOMER_ID INNER JOIN
                                                                                             dbo.CUSTOMER AS employee ON 
                                                                                             employee.MASTER_CUSTOMER_ID = CUS_RELATIONSHIP_2.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                                                                                             dbo.ORDER_MASTER AS ORDER_MASTER_5 ON 
                                                                                             ORDER_MASTER_5.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID AND 
                                                                                             ORDER_MASTER_5.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                                                                                             dbo.ORDER_DETAIL AS ORDER_DETAIL_5 ON ORDER_MASTER_5.ORDER_NO = ORDER_DETAIL_5.ORDER_NO
                                                                      WHERE      (CUS_RELATIONSHIP_2.RELATIONSHIP_CODE = 'EMPLOYEE') AND (ISNULL(CUS_RELATIONSHIP_2.BEGIN_DATE, DATEADD(day, 
                                                                                             - 1, SYSDATETIME())) <= SYSDATETIME()) AND (ISNULL(CUS_RELATIONSHIP_2.END_DATE, DATEADD(day, 1, SYSDATETIME())) 
                                                                                             >= SYSDATETIME()) AND (ISNULL(ORDER_DETAIL_5.CYCLE_BEGIN_DATE, DATEADD(day, - 1, SYSDATETIME())) <= SYSDATETIME()) 
                                                                                             AND (ISNULL(ORDER_DETAIL_5.CYCLE_END_DATE, DATEADD(day, 1, SYSDATETIME())) >= SYSDATETIME())) 
                                                                     AS segment_employee_control
                                              GROUP BY EMPLOYEE_ID, EMPLOYEE_NAME
                                              HAVING      (COUNT(ORG_ID) > 1)) AS test INNER JOIN
                                             dbo.CUS_RELATIONSHIP AS CUS_RELATIONSHIP_1 ON test.EMPLOYEE_ID = CUS_RELATIONSHIP_1.MASTER_CUSTOMER_ID) 
                      AS seg_multiple INNER JOIN
                      dbo.CUSTOMER AS employer ON employer.MASTER_CUSTOMER_ID = seg_multiple.EMPLOYER_ID INNER JOIN
                      dbo.CUSTOMER AS employee ON employee.MASTER_CUSTOMER_ID = seg_multiple.EMPLOYEE_ID INNER JOIN
                      dbo.APP_ORGANIZATION AS app_org ON app_org.ORG_ID = employer.ORG_ID LEFT OUTER JOIN
                      dbo.CUS_SEGMENT_CONTROL AS seg_control ON seg_control.MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID AND 
                      seg_control.SEGMENT_QUALIFIER1 = employer.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                      dbo.ORDER_MASTER AS employee_order_master ON employee_order_master.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID AND 
                      employee_order_master.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                      dbo.ORDER_DETAIL AS employee_order_detail ON employee_order_master.ORDER_NO = employee_order_detail.ORDER_NO LEFT OUTER JOIN
                      dbo.ORDER_MASTER AS employer_order_master ON employer_order_master.SHIP_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID AND 
                      employer_order_master.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID LEFT OUTER JOIN
                      dbo.ORDER_DETAIL AS employer_order_detail ON employer_order_master.ORDER_NO = employer_order_detail.ORDER_NO LEFT OUTER JOIN
                      dbo.CUS_ADDRESS AS employee_address ON employee_order_master.SHIP_ADDRESS_ID = employee_address.CUS_ADDRESS_ID LEFT OUTER JOIN
                      dbo.CUS_ADDRESS AS employer_address ON employer_order_master.SHIP_ADDRESS_ID = employer_address.CUS_ADDRESS_ID
WHERE     (employee_order_detail.CYCLE_BEGIN_DATE IS NULL) AND (employer_order_detail.CYCLE_BEGIN_DATE IS NULL) OR
                      (employee_order_detail.CYCLE_BEGIN_DATE IS NULL) AND (employer_order_detail.ORDER_NO =
                          (SELECT     TOP (1) ORDER_MASTER_4.ORDER_NO
                            FROM          dbo.ORDER_MASTER AS ORDER_MASTER_4 INNER JOIN
                                                   dbo.ORDER_DETAIL AS ORDER_DETAIL_4 ON ORDER_MASTER_4.ORDER_NO = ORDER_DETAIL_4.ORDER_NO
                            WHERE      (ORDER_MASTER_4.SHIP_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID) AND 
                                                   (ORDER_MASTER_4.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID)
                            ORDER BY ORDER_DETAIL_4.CYCLE_END_DATE DESC)) OR
                      (employer_order_detail.CYCLE_BEGIN_DATE IS NULL) AND (employee_order_detail.ORDER_NO =
                          (SELECT     TOP (1) ORDER_MASTER_2.ORDER_NO
                            FROM          dbo.ORDER_MASTER AS ORDER_MASTER_2 INNER JOIN
                                                   dbo.ORDER_DETAIL AS ORDER_DETAIL_2 ON ORDER_MASTER_2.ORDER_NO = ORDER_DETAIL_2.ORDER_NO
                            WHERE      (ORDER_MASTER_2.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID) AND 
                                                   (ORDER_MASTER_2.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID)
                            ORDER BY ORDER_DETAIL_2.CYCLE_END_DATE DESC)) OR
                      (employer_order_detail.ORDER_NO =
                          (SELECT     TOP (1) ORDER_MASTER_3.ORDER_NO
                            FROM          dbo.ORDER_MASTER AS ORDER_MASTER_3 INNER JOIN
                                                   dbo.ORDER_DETAIL AS ORDER_DETAIL_3 ON ORDER_MASTER_3.ORDER_NO = ORDER_DETAIL_3.ORDER_NO
                            WHERE      (ORDER_MASTER_3.SHIP_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID) AND 
                                                   (ORDER_MASTER_3.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID)
                            ORDER BY ORDER_DETAIL_3.CYCLE_END_DATE DESC)) AND (employee_order_detail.ORDER_NO =
                          (SELECT     TOP (1) ORDER_MASTER_1.ORDER_NO
                            FROM          dbo.ORDER_MASTER AS ORDER_MASTER_1 INNER JOIN
                                                   dbo.ORDER_DETAIL AS ORDER_DETAIL_1 ON ORDER_MASTER_1.ORDER_NO = ORDER_DETAIL_1.ORDER_NO
                            WHERE      (ORDER_MASTER_1.SHIP_MASTER_CUSTOMER_ID = employee.MASTER_CUSTOMER_ID) AND 
                                                   (ORDER_MASTER_1.BILL_MASTER_CUSTOMER_ID = employer.MASTER_CUSTOMER_ID)
                            ORDER BY ORDER_DETAIL_1.CYCLE_END_DATE DESC))
ORDER BY EMPLOYEE_LABEL_NAME, EMPLOYER_LABEL_NAME

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -192
         Left = 0
      End
      Begin Tables = 
         Begin Table = "seg_multiple"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 110
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "employer"
            Begin Extent = 
               Top = 6
               Left = 236
               Bottom = 125
               Right = 545
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "employee"
            Begin Extent = 
               Top = 6
               Left = 583
               Bottom = 125
               Right = 892
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "app_org"
            Begin Extent = 
               Top = 6
               Left = 930
               Bottom = 125
               Right = 1172
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "seg_control"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 304
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "employee_order_master"
            Begin Extent = 
               Top = 126
               Left = 342
               Bottom = 245
               Right = 612
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "employee_order_detail"
            Begin Extent = 
               Top = 126
               Left = 650
               Bottom = 245
               Right = 941
        ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'usr_employee_multiple_employers_20140728'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'    End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "employer_order_master"
            Begin Extent = 
               Top = 126
               Left = 979
               Bottom = 245
               Right = 1249
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "employer_order_detail"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 329
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "employee_address"
            Begin Extent = 
               Top = 246
               Left = 367
               Bottom = 365
               Right = 641
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "employer_address"
            Begin Extent = 
               Top = 246
               Left = 679
               Bottom = 365
               Right = 953
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'usr_employee_multiple_employers_20140728'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'usr_employee_multiple_employers_20140728'
GO


