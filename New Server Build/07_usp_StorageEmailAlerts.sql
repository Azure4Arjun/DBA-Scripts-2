
USE DBA
IF OBJECT_ID('dbo.usp_StorageEmailAlerts') IS NOT NULL
	DROP PROCEDURE dbo.usp_StorageEmailAlerts
GO

CREATE PROC dbo.usp_StorageEmailAlerts
			@Profile		sysname,
			@To				varchar(max),
			@Threshold		INT				-- Numberof MBs for the alert to launch
AS

	DECLARE @sbj	varchar(100)=	'Low Storage Alert On: ' + @@servername
	SET NOCOUNT ON

	IF OBJECT_ID('tempdb..#Drives') IS NOT NULL
		DROP TABLE #Drives 
	CREATE TABLE #Drives 
	(
		Drive		Char,
		FreeMB		INT
	)

	INSERT INTO #Drives (Drive, FreeMB)
	EXEC  master..xp_fixeddrives

	IF EXISTS(SELECT * FROM #Drives WHERE FreeMB < @Threshold)

	BEGIN
		DECLARE @message varchar(100)
	
		SET @message = CHAR(13) + CHAR(9) + 'Warning, the following drives are below the threshold of '+ CAST(@Threshold AS varchar(100)) +' MB:' + CHAR(13) + CHAR(13) + CHAR(9)
		SELECT @message= @message + ' ' + Drive + ': ' +   CAST(FreeMB AS varchar(100)) + ' MB' + CHAR(13) + CHAR(9)  FROM #Drives WHERE FreeMB < @Threshold
	--PRINT @Message																																	-- Testing
	
		EXEC msdb.dbo.sp_send_dbmail 
				@profile_name = @Profile,
				@recipients = @To, 
				@Subject = @sbj, 
				@body =  @message,
				@importance = 'high';

		DROP TABLe #Drives
	END
GO



-- testing
--EXEC dba.dbo.usp_StorageEmailAlerts 'Internal', 'hantochow@retailinsight.co.uk', 200000


--EXEC dba.dbo.usp_StorageEmailAlerts 'RIS101 SQL Server', 'hantochow@retailinsight.co.uk', 200000



--EXEC dba.dbo.usp_StorageEmailAlerts 
--		@Profile =		'Internal',
--		@To =			'dbaAlerts@retailinsight.co.uk', 
--		@Threshold =	10000;



