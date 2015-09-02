USE [DBA]
GO

/****** Object:  Table [dbo].[LogSpaceAudit]    Script Date: 21/08/2015 16:24:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LogSpaceAudit](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[dt] [datetime] NULL,
	[dbName] [sysname] NOT NULL,
	[logSize] [decimal](18, 5) NULL,
	[logUsed] [decimal](18, 5) NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[LogSpaceAudit] ADD  DEFAULT (getdate()) FOR [dt]
GO

-------------------------------------------------------------


USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[usp_GetLogStats]    Script Date: 21/08/2015 16:24:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_GetLogStats] @DayRetention int = 31
AS
SET NOCOUNT ON;


IF OBJECT_ID(N'tempdb..#tLogSpaceAudit', N'U') IS NOT NULL
	DROP TABLE #tLogSpaceAudit 

CREATE TABLE #tLogSpaceAudit 
(
	dbName	sysname
,	logSize decimal(18,5)
,	logUsed decimal(18,5)
,	[status] int
)

INSERT INTO #tLogSpaceAudit
	EXEC usp_SQLPerf

INSERT INTO dbo.LogSpaceAudit(dbName, logSize, logUsed)
SELECT	dbName, logSize, logUsed
FROM	#tLogSpaceAudit

DROP TABLE #tLogSpaceAudit

-- Maintenace - delete @DayRetention days (31 - default)
WHILE 1 = 1
BEGIN 
	DELETE TOP(1000) FROM dbo.LogSpaceAudit
	WHERE	dt < DATEADD(dd, -@DayRetention, GETDATE())
	IF @@ROWCOUNT < 10 BREAK;
END


GO


-----------------


USE [msdb]
GO

/****** Object:  Job [Operations - LogSpaceMonitor]    Script Date: 21/08/2015 16:18:52 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 21/08/2015 16:18:52 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Operations - LogSpaceMonitor', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'Database notification', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA.dbo.usp_GetLogStats]    Script Date: 21/08/2015 16:18:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA.dbo.usp_GetLogStats', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC DBA.dbo.usp_GetLogStats 31', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 5 min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150424, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'ae8e4f07-28cc-4d91-a4e9-1e818905ec02'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

