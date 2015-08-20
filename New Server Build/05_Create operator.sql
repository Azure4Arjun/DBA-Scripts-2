USE [msdb]
GO

/****** Object:  Operator [Database notification]    Script Date: 04/28/2010 13:38:26 ******/
EXEC msdb.dbo.sp_add_operator @name=N'Database notification', 
		@enabled=1, 
		@email_address=N'dbaAlerts@retailinsight.co.uk', 
		@category_name=N'[Uncategorized]'
GO

