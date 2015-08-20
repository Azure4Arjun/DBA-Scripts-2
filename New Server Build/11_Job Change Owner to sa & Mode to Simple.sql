USE [msdb]
GO

/****** Object:  Job [Operations - Change Owner to sa & Recovery Mode to SIMPLE]    Script Date: 26/03/2014 11:35:03 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 26/03/2014 11:35:03 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Operations - Change Owner to sa & Recovery Mode to SIMPLE', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'Database notification', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Cursor]    Script Date: 26/03/2014 11:35:03 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Cursor', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
-- Change Recovery Model to SIMPLE
-- Change DB Owner to sa

SET NOCOUNT ON

DECLARE @DB_Name	AS nvarchar(256)
DECLARE @Owner		AS varbinary
DECLARE @RecMode	AS tinyint
DECLARE @SQL1		AS nvarchar(max)
DECLARE @SQL2		AS nvarchar(max)


--SELECT ALL DBs
DECLARE curDBName CURSOR FOR
	SELECT name, owner_sid, recovery_model
	FROM master.sys.databases
	WHERE name NOT IN (''master'', ''model'', ''msdb'', ''tempdb'')
	AND source_database_id IS NULL	-- snapshots
	AND state = 0			--offline


OPEN curDBName 
FETCH NEXT FROM curDBName INTO @DB_Name, @Owner, @RecMode
WHILE @@FETCH_STATUS  = 0
BEGIN

	IF  @Owner <> ''0x01''
	BEGIN
		SET @SQL2 = ''ALTER AUTHORIZATION ON DATABASE::['' + @DB_Name + ''] TO sa;''
		EXEC sp_executesql @SQL2 
	END 

	IF @RecMode <> 3
	BEGIN
		SET @SQL1 = ''ALTER DATABASE ['' + @DB_Name + ''] SET RECOVERY SIMPLE;''
		EXEC sp_executesql @SQL1
	END
	FETCH NEXT FROM curDBName INTO @DB_name, @Owner, @RecMode
END

CLOSE curDBName
DEALLOCATE curDBName


-- check
--select name, owner_sid, recovery_model_desc from sys.databases


', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily @ Midnight', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140326, 
		@active_end_date=99991231, 
		@active_start_time=1, 
		@active_end_time=235959,
		@schedule_uid=N'893813d2-4b9b-42c3-b9d0-c2f41773952c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


