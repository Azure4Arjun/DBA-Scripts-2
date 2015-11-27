





USE DBA;

CREATE TABLE dbo.ErrorLogArchive
(	ErrorLogArchiveID	INT IDENTITY(1,1)	NOT NULL
,	LogDate				DATETIME			NULL
,	ProcessInfo			VARCHAR(50)			NULL
,	[Text]				NVARCHAR(MAX)		NULL
	CONSTRAINT PK_ErrorLogArchive PRIMARY KEY (ErrorLogArchiveID)
)
GO

IF OBJECT_ID('dbo.usp_archive_error_log', N'P') IS NOT NULL
	DROP PROCEDURE dbo.usp_archive_error_log
GO

CREATE PROCEDURE dbo.usp_archive_error_log
AS

	EXEC sys.sp_cycle_errorlog

	IF (@@ERROR = 0)
	BEGIN
		INSERT INTO dbo.ErrorLogArchive
	        ( LogDate ,
	          ProcessInfo ,
	          [Text]
	        )
		EXEC sys.sp_readerrorlog 1
	END


EXEC dbo.usp_archive_error_log

