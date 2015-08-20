--
-- Create DBA database
--
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DBA')
BEGIN
	CREATE DATABASE DBA;

	ALTER DATABASE DBA SET RECOVERY SIMPLE;
		
	ALTER DATABASE DBA MODIFY FILE (name = 'DBA', size = 200MB)
	ALTER DATABASE DBA MODIFY FILE (name = 'DBA_log', size = 50MB)
	ALTER DATABASE DBA MODIFY FILE (name = 'DBA', filegrowth = 100MB)
	ALTER DATABASE DBA MODIFY FILE (name = 'DBA_log', filegrowth = 10MB)
END
GO

ALTER AUTHORIZATION ON DATABASE::DBA TO sa;
GO

USE [DBA]
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[FreeSpaceAudit](
	[DateRecorded] [date] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[FileID] [int] NOT NULL,
	[FileSizeMB] [decimal](12, 2) NOT NULL,
	[SpaceUsedMB] [decimal](12, 2) NOT NULL,
	[FreeSpaceMB] [decimal](12, 2) NOT NULL,
	[PercentageFull] [decimal](12, 2) NOT NULL,
	[LogicalFileName] [sysname] NOT NULL,
	[Filename] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_FreeSpaceAudit] PRIMARY KEY CLUSTERED 
(
	[DatabaseName] ASC,
	[FileID] ASC,
	[DateRecorded] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


CREATE PROCEDURE [dbo].[RecordFreeSpace]
AS
	SET NOCOUNT ON

	DECLARE 
		@CurrentDB sysname,
		@SQL NVARCHAR(MAX);

	DECLARE DBCursor CURSOR FORWARD_ONLY STATIC READ_ONLY
	FOR SELECT name FROM sys.databases WHERE state_desc = 'ONLINE';

	OPEN DBCursor;

	FETCH NEXT FROM DBCursor INTO @CurrentDB;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @SQL = N'
		USE ' + QUOTENAME(@CurrentDB) + '
		INSERT INTO DBA.dbo.FreeSpaceAudit
		SELECT
			CAST(CURRENT_TIMESTAMP AS DATE),      
			DB_NAME() AS DatabaseName,      
			a.file_id,
			[FILE_SIZE_MB] = convert(decimal(12,2),round(a.size/128.000,2)),
			[SPACE_USED_MB] = convert(decimal(12,2),round(fileproperty(a.name,''SpaceUsed'')/128.000,2)),
			[FREE_SPACE_MB] = convert(decimal(12,2),round((a.size-fileproperty(a.name,''SpaceUsed''))/128.000,2)) ,
			PercentageFull = CONVERT(DECIMAL(12,2),((convert(decimal(12,2),round(fileproperty(a.name,''SpaceUsed'')/128.000,2)))/(convert(decimal(12,2),round(a.size/128.000,2))) * 100)),
			LogicalName = a.NAME,
			a.physical_name
		FROM sys.database_files a
		WHERE a.type_desc <> ''LOG'';';

		EXEC sp_executesql @SQL;
	
		FETCH NEXT FROM DBCursor INTO @CurrentDB;
	END

	CLOSE DBCursor;
	DEALLOCATE DBCursor;



