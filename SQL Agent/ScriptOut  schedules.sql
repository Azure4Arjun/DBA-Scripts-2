SET NOCOUNT ON
GO

SELECT name, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE('EXEC msdb.dbo.sp_add_schedule @schedule_name = ''%1'', @enabled = 1, @freq_type = %2, @freq_interval = %3, @freq_subday_type = %4, @freq_subday_interval = %5, @freq_relative_interval = %6, @freq_recurrence_factor = %7, @active_start_date = 20130601, @active_end_date = 99991231, @active_start_time = 0, @active_end_time = 0, @owner_login_name = ''sa'';
GO', '%1', name), '%2', CAST(freq_type AS nvarchar)), '%3', CAST(freq_interval AS nvarchar)), '%4', CAST(freq_subday_type AS nvarchar)), '%5', CAST(freq_subday_interval AS nvarchar)), '%6', CAST(freq_relative_interval AS nvarchar)), '%7', CAST(freq_recurrence_factor AS nvarchar))
FROM dbo.sysschedules AS S 
GO