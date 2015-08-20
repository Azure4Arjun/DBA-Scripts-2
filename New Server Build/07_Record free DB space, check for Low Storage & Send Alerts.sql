USE [msdb]
GO

/****** Object:  Job [Operations - Record free DB space, check for Low Storage & Send Alerts]    Script Date: 02/04/2014 10:16:31 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 02/04/2014 10:16:31 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Operations - Record free DB space, check for Low Storage & Send Alerts', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'Database notification', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database Free Space Warning Alert]    Script Date: 02/04/2014 10:16:31 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database Free Space Warning Alert', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @sbj nvarchar(400);
SET @sbj = ''** '' + @@SERVERNAME +'' - Database free space warning **''

USE DBA;

EXEC DBA.dbo.RecordFreeSpace;

	IF EXISTS (	SELECT *
				FROM DBA.dbo.FreeSpaceAudit
				WHERE DateRecorded = (SELECT MAX(DateRecorded) FROM DBA.dbo.FreeSpaceAudit)
				AND dbo.FreeSpaceAudit.PercentageFull > 90)
	BEGIN
		EXEC msdb..sp_send_dbmail 
			@recipients = ''dbaAlerts@retailinsight.co.uk'', 
			@subject = @sbj,
			@attach_query_result_as_file = 0,
			@importance = ''HIGH'',
			@query_result_header = 0,
			@body_format = ''TEXT'',
			@query = ''
				SET NOCOUNT ON
				SELECT DatabaseName + ''''/'''' + LogicalFileName + ''''  is '''' + CAST(PercentageFull as varchar(10)) + ''''% full''''
				FROM DBA.dbo.FreeSpaceAudit
				WHERE DateRecorded = (SELECT MAX(DateRecorded) FROM DBA.dbo.FreeSpaceAudit)
				AND PercentageFull > 90''; 
	END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [usp_StorageEmailAlerts]    Script Date: 02/04/2014 10:16:31 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'usp_StorageEmailAlerts', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dba.dbo.usp_StorageEmailAlerts 
		@Profile =		''Internal'',
		@To =			''dbaAlerts@retailinsight.co.uk'', 
		@Threshold =		10000;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20130822, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'd632b97f-0936-4a33-80bc-a4544f349793'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


