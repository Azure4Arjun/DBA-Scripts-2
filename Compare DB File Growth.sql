



-- Compare DB file growth (only data files)

DECLARE @date1 date	= GETDATE()
,		@date2 date = DATEADD(day,-1,GETDATE())

SELECT	[Filename]
,		MAX(CASE WHEN DateRecorded = @date1
			THEN FileSizeMB END)					AS [20150805]
,		MAX(CASE WHEN DateRecorded = @date2
			THEN FileSizeMB END)					AS [20150804]
,		MAX(CASE WHEN DateRecorded = @date1
			THEN FileSizeMB END)	
-		MAX(CASE WHEN DateRecorded = @date2
			THEN FileSizeMB END)					AS [SizeDiff]
FROM dba.[dbo].[FreeSpaceAudit]
WHERE DateRecorded >= @date2
GROUP BY [Filename]
ORDER BY [SizeDiff] DESC

