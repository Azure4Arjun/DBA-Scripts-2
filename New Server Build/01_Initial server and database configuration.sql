
/*
	Setup system and tempdb files
*/

SELECT @@SERVERNAME

-- ==================
-- Add BUILTIN\Administrators account to SYSADMINs group
-- ==================
USE [master]
GO
CREATE LOGIN [BUILTIN\Administrators] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
EXEC master..sp_addsrvrolemember @loginame = N'BUILTIN\Administrators', @rolename = N'sysadmin'
GO


-- ===================
-- Server Level Configuration
-- ===================
EXEC sp_configure;
EXEC sp_configure 'show advanced options',1;RECONFIGURE;
EXEC sp_configure 'backup compression default',1;RECONFIGURE WITH OVERRIDE;
EXEC sp_configure 'max degree of parallelism',4;RECONFIGURE WITH OVERRIDE;  -- If required
EXEC sp_configure 'max server memory (MB)',30000;RECONFIGURE WITH OVERRIDE; 
EXEC sys.sp_configure N'cost threshold for parallelism', N'50'; RECONFIGURE WITH OVERRIDE; 



-- ==================
-- Change the default system databases location 
-- ==================
USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultData', REG_SZ, N'D:\MSSQL\Data'
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'DefaultLog', REG_SZ, N'D:\MSSQL\Log'
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory', REG_SZ, N'D:\MSSQL\Backup'
GO



-- ================
-- Pre-size system database files 
-- ================
exec sp_helpdb master;
alter database master modify file (name = 'master', size = 100MB)
alter database master modify file (name = 'master', filegrowth = 10MB)
alter database master modify file (name = 'mastlog', size = 50MB)
alter database master modify file (name = 'mastlog', filegrowth = 10MB)

exec sp_helpdb msdb;
alter database msdb modify file (name = 'MSDBData', size = 500MB)
alter database msdb modify file (name = 'MSDBData', filegrowth = 100MB)
alter database msdb modify file (name = 'MSDBLog', size = 100MB)
alter database msdb modify file (name = 'MSDBLog', filegrowth = 100MB)

exec sp_helpdb model;
ALTER DATABASE model SET RECOVERY SIMPLE;
alter database model modify file (name = 'modeldev', size = 100MB)
alter database model modify file (name = 'modeldev', filegrowth = 1000MB)
alter database model modify file (name = 'modellog', size = 100MB)
alter database model modify file (name = 'modellog', filegrowth = 1000MB)

exec sp_helpdb ReportServer;
ALTER DATABASE ReportServer SET RECOVERY SIMPLE;
alter database ReportServer modify file (name = 'ReportServer', size = 100MB)
alter database ReportServer modify file (name = 'ReportServer', filegrowth = 100MB)
alter database ReportServer modify file (name = 'ReportServer_log', size = 100MB)
alter database ReportServer modify file (name = 'ReportServer_log', filegrowth = 100MB)

exec sp_helpdb ReportServerTempDB;
alter database ReportServerTempDB modify file (name = 'ReportServerTempDB', size = 100MB)
alter database ReportServerTempDB modify file (name = 'ReportServerTempDB', filegrowth = 100MB)
alter database ReportServerTempDB modify file (name = 'ReportServerTempDB_log', size = 100MB)
alter database ReportServerTempDB modify file (name = 'ReportServerTempDB_log', filegrowth = 100MB)

-- =============
-- Tempdb config
-- =============
exec sp_helpdb tempdb;

-- Move existing (if not in correct location)
ALTER DATABASE tempdb MODIFY FILE ( NAME = tempdev , FILENAME = 'D:\MSSQL\Data\tempdb.mdf' );
ALTER DATABASE tempdb MODIFY FILE ( NAME = templog , FILENAME = 'D:\MSSQL\Log\templog.ldf' );

-- Resize existing
alter database tempdb modify file (name = tempdev, size = 20GB);
alter database tempdb modify file (name = tempdev, filegrowth = 2GB);
alter database tempdb modify file (name = templog, size = 10GB);
alter database tempdb modify file (name = templog, filegrowth = 1GB);

-- Add new data files
alter database tempdb add file (name = tempdb_data2, filename = 'D:\MSSQL\Data\tempdb_data2.ndf',size = 20GB, filegrowth = 2GB);
alter database tempdb add file (name = tempdb_data3, filename = 'D:\MSSQL\Data\tempdb_data3.ndf',size = 20GB, filegrowth = 2GB);
--alter database tempdb add file (name = tempdb_data4, filename = 'E:\MSSQL$SQL2014_2\TempDB\Data\tempdb_data4.ndf',size = 20GB, filegrowth = 2GB);

-- ======================
-- Fix database ownership
-- ======================
EXEC sp_helpdb;
ALTER AUTHORIZATION ON DATABASE::ReportServer TO sa;
ALTER AUTHORIZATION ON DATABASE::ReportServerTempDB TO sa;
GO

