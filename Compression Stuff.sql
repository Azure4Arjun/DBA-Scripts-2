



EXEC sp_estimate_data_compression_savings 'epos','sale',1,1,ROW
EXEC sp_estimate_data_compression_savings 'epos','sale',1,1,PAGE




SELECT	OBJECT_SCHEMA_NAME(object_id, DB_ID()) + '.' + OBJECT_NAME(object_id) As ObjectName
,		*
FROM sys.partitions
ORDER BY rows DESC


