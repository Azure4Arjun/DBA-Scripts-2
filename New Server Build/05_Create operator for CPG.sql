USE [msdb]
GO

/****** Object:  Operator [Database notification]    Script Date: 04/28/2010 13:38:26 ******/
EXEC msdb.dbo.sp_add_operator @name=N'CPG Operators', 
		@enabled=1, 
		@email_address=N'cpgops@retailinsight.co.uk', 
		@category_name=N'[Uncategorized]'
GO

