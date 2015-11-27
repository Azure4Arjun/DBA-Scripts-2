USE [master]
GO

/****** Object:  DdlTrigger [DBA_Database_Alerts]    Script Date: 23/09/2014 10:56:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM sys.server_triggers

CREATE TRIGGER [DBA_Database_Alerts]
ON ALL SERVER
FOR DROP_DATABASE,CREATE_DATABASE,ALTER_DATABASE
AS
	SET NOCOUNT ON
    
	DECLARE 
		@Message		nvarchar(max),
		@Command		nvarchar(max), 
		@Subject		nvarchar(200),
		@Database		sysname,
		@Prevent		tinyint,
		@RecipientsList nvarchar(100);

	SET @RecipientsList = 'dbaAlerts@retailinsight.co.uk';

	-- ========================
	-- Build normal alert email
	-- ========================        
	SELECT @Database	= EVENTDATA().value('(/EVENT_INSTANCE/DatabaseName)[1]','nvarchar(max)');
	SELECT @Message		= 'Database: ' + @Database + CHAR(13);
	SELECT @Message		= @Message + 'User: ' + EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','nvarchar(max)') + CHAR(13);
	SELECT @Message		= @Message + 'Command: ' + EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)');
	SELECT @Command		= EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]','nvarchar(max)');
	SELECT @Subject		= '*** ' + @@SERVERNAME + ' - ' + @command + ' ***';
    
	-- ===================================================
	-- Check if this is a database that we need to protect
	-- ===================================================
	SET @Prevent = 0;

	IF (@Command LIKE '%drop%')
	BEGIN
		IF (@@SERVERNAME = '691139-DB8\CEEMA_PRD' AND @Database = 'PM_APP') SET @Prevent = 1; -- V8 CEEMA PROD
		IF (@@SERVERNAME = '691139-DB8\CEEMA_PRD' AND @Database = 'PM_EDW') SET @Prevent = 1; -- V8 CEEMA PROD
		IF (@@SERVERNAME = '691139-DB8\CEEMA_PRD' AND @Database = 'PM_ETL') SET @Prevent = 1; -- V8 CEEMA PROD
		IF (@@SERVERNAME = '691139-DB8\CEEMA_PRD' AND @Database = 'PM_STG') SET @Prevent = 1; -- V8 CEEMA PROD

		IF (@@SERVERNAME = '690670-DB9' AND @Database = 'PM_APP') SET @Prevent = 1; -- V8 AP PROD
		IF (@@SERVERNAME = '690670-DB9' AND @Database = 'PM_EDW') SET @Prevent = 1; -- V8 AP PROD
		IF (@@SERVERNAME = '690670-DB9' AND @Database = 'PM_ETL') SET @Prevent = 1; -- V8 AP PROD
		IF (@@SERVERNAME = '690670-DB9' AND @Database = 'PM_STG') SET @Prevent = 1; -- V8 AP PROD

		IF (@@SERVERNAME = '712468-DB12\DIAGEO_PRD' AND @Database = 'PM_APP') SET @Prevent = 1; -- V8 DIAGEO PROD
		IF (@@SERVERNAME = '712468-DB12\DIAGEO_PRD' AND @Database = 'PM_EDW') SET @Prevent = 1; -- V8 DIAGEO PROD
		IF (@@SERVERNAME = '712468-DB12\DIAGEO_PRD' AND @Database = 'PM_ETL') SET @Prevent = 1; -- V8 DIAGEO PROD
		IF (@@SERVERNAME = '712468-DB12\DIAGEO_PRD' AND @Database = 'PM_STG') SET @Prevent = 1; -- V8 DIAGEO PROD

		IF (@@SERVERNAME = '712468-DB12\KC_PRD' AND @Database = 'PM_APP') SET @Prevent = 1; -- V8 KC PROD
		IF (@@SERVERNAME = '712468-DB12\KC_PRD' AND @Database = 'PM_EDW') SET @Prevent = 1; -- V8 KC PROD
		IF (@@SERVERNAME = '712468-DB12\KC_PRD' AND @Database = 'PM_ETL') SET @Prevent = 1; -- V8 KC PROD
		IF (@@SERVERNAME = '712468-DB12\KC_PRD' AND @Database = 'PM_STG') SET @Prevent = 1; -- V8 KC PROD

		IF (@@SERVERNAME = '657188-DB22' AND @Database = 'PM_APP') SET @Prevent = 1;	-- V8 JDE PROD
		IF (@@SERVERNAME = '657188-DB22' AND @Database = 'PM_EDW') SET @Prevent = 1;	-- V8 JDE PROD
		IF (@@SERVERNAME = '657188-DB22' AND @Database = 'PM_ETL') SET @Prevent = 1;	-- V8 JDE PROD
		IF (@@SERVERNAME = '657188-DB22' AND @Database = 'PM_STG') SET @Prevent = 1;	-- V8 JDE PROD

		IF (@@SERVERNAME = '657188-DB22\LAVAZZA' AND @Database = 'PM_APP') SET @Prevent = 1;	-- V8 LAVAZZA PROD
		IF (@@SERVERNAME = '657188-DB22\LAVAZZA' AND @Database = 'PM_EDW') SET @Prevent = 1;	-- V8 LAVAZZA PROD
		IF (@@SERVERNAME = '657188-DB22\LAVAZZA' AND @Database = 'PM_ETL') SET @Prevent = 1;	-- V8 LAVAZZA PROD
		IF (@@SERVERNAME = '657188-DB22\LAVAZZA' AND @Database = 'PM_STG') SET @Prevent = 1;	-- V8 LAVAZZA PROD
		
		IF (@@SERVERNAME = '691146-DB7' AND @Database = 'OSA_ETL_Framework_Admin')		SET @Prevent = 1; -- SONAE
		IF (@@SERVERNAME = '691146-DB7' AND @Database = 'OSA_Sonae_Engine')				SET @Prevent = 1; -- SONAE
		IF (@@SERVERNAME = '691146-DB7' AND @Database = 'OSA_Sonae_ItemStoreBucketDay')	SET @Prevent = 1; -- SONAE
		IF (@@SERVERNAME = '691146-DB7' AND @Database = 'OSA_Sonae_Reporting')			SET @Prevent = 1; -- SONAE
		IF (@@SERVERNAME = '691146-DB7' AND @Database = 'OSA_Sonae_Stage')				SET @Prevent = 1; -- SONAE
		IF (@@SERVERNAME = '691146-DB7' AND @Database = 'OSCA_Sandbox')					SET @Prevent = 1; -- SONAE

		IF (@@SERVERNAME = '452925-DB6' AND @Database = 'CAIT_ETL_Framework_Admin')		SET @Prevent = 1; -- WmM PROD
		IF (@@SERVERNAME = '452925-DB6' AND @Database = 'CAIT_WmM_Engine')				SET @Prevent = 1; -- WmM PROD
		IF (@@SERVERNAME = '452925-DB6' AND @Database = 'CAIT_WmM_ItemStoreBucketDay')	SET @Prevent = 1; -- WmM PROD
		IF (@@SERVERNAME = '452925-DB6' AND @Database = 'CAIT_WmM_Reporting')			SET @Prevent = 1; -- WmM PROD
		IF (@@SERVERNAME = '452925-DB6' AND @Database = 'CAIT_WmM_Stage')				SET @Prevent = 1; -- WmM PROD

		IF (@@SERVERNAME = '582962-DB16' AND @Database = 'CAIT_ETL_Framework_Admin')	SET @Prevent = 1; -- JS PROD
		IF (@@SERVERNAME = '582962-DB16' AND @Database = 'CAIT_JS_Engine')				SET @Prevent = 1; -- JS PROD
		IF (@@SERVERNAME = '582962-DB16' AND @Database = 'CAIT_JS_ItemStoreBucketDay')	SET @Prevent = 1; -- JS PROD
		IF (@@SERVERNAME = '582962-DB16' AND @Database = 'CAIT_JS_Reporting')			SET @Prevent = 1; -- JS PROD
		IF (@@SERVERNAME = '582962-DB16' AND @Database = 'CAIT_JS_Stage')				SET @Prevent = 1; -- JS PROD
		IF (@@SERVERNAME = '582962-DB16' AND @Database = 'Scratch')						SET @Prevent = 1; -- JS PROD

		IF (@@SERVERNAME = '582963-DB17' AND @Database = 'CAMReporting')				SET @Prevent = 1; -- JS PROD

		IF (@@SERVERNAME = '604864-DB20' AND @Database = 'OSCA_ETL_Framework_Admin')	SET @Prevent = 1; -- ASDA WASTE
		IF (@@SERVERNAME = '604864-DB20' AND @Database = 'Wastage_Engine')				SET @Prevent = 1; -- ASDA WASTE
		IF (@@SERVERNAME = '604864-DB20' AND @Database = 'Wastage_Reporting')			SET @Prevent = 1; -- ASDA WASTE
		IF (@@SERVERNAME = '604864-DB20' AND @Database = 'Wastage_Stage')				SET @Prevent = 1; -- ASDA WASTE

		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Danone_Epos')							SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Danone_OscaLite_Engine')				SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Danone_OscaLite_ETL_Framework_Admin')	SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Danone_OscaLite_ItemStoreBucketDay')	SET @Prevent = 1; -- COMPASS	
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Danone_OscaLite_Reporting')			SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Danone_OscaLite_Stage')				SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Diageo_Epos')							SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Diageo_OscaLite_Engine')				SET @Prevent = 1; -- COMPASS	
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Diageo_OscaLite_ETL_Framework_Admin')	SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Diageo_OscaLite_ItemStoreBucketDay')	SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Diageo_OscaLite_Reporting')			SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Diageo_OscaLite_Stage')				SET @Prevent = 1; -- COMPASS	
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'Epos')								SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'OscaLite_Engine')						SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'OscaLite_ETL_Framework_Admin')		SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'OscaLite_ItemStoreBucketDay')			SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'OscaLite_Reporting')					SET @Prevent = 1; -- COMPASS
		IF (@@SERVERNAME = '712467-DB15' AND @Database = 'OscaLite_Stage')						SET @Prevent = 1; -- COMPASS

END
			
	-- ==============================================================
	-- Prevent action if protected, otherwise continue and send email
	-- ==============================================================
	IF (@Prevent = 1)
	BEGIN
		PRINT '**** Database ' + @Database + ' is PRODUCTION, you need to disable the trigger "DBA_Database_Alerts" to drop this database ***';
		
		ROLLBACK;
	END 
	ELSE
	BEGIN
		EXEC msdb..sp_send_dbmail 
			@recipients = @RecipientsList,
			@subject = @Subject,
			@body = @Message
	END 



GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

ENABLE TRIGGER [DBA_Database_Alerts] ON ALL SERVER
GO

