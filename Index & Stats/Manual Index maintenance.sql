

-- Analyzing index problems

ELECT * FROM sys.indexes
WHERE name = 'ItemStoreDayException_PK'

-- Check the size of the index
SELECT 	page_count * 128 / 1024 AS GB 
,* 
FROM sys.dm_db_index_physical_stats(DB_ID(),2105058535, NULL,NULL,NULL)



-- Manually run Ola's script to update the index.
EXEC DBA.[dbo].[IndexOptimize]  @Databases = 'CAIT_JS_Reporting', @SortInTempdB = 'Y', @Indexes = '[CAIT_JS_Reporting].[Availability].[ItemStoreDayException].ItemStoreDayException_PK', @LockTimeout = 600000;


