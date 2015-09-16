

-- Enable Database Mail for this instance
EXEC sp_configure 'show advanced', 1;
RECONFIGURE;
GO
EXEC sp_configure 'Database Mail XPs',1;
RECONFIGURE;
GO
 
DECLARE @account_name sysname 					= '712466-DB21(Internal) Mandrill'					-- E.g: DB12 KC_PROD
,		@displayname nvarchar(128) 				= '(Internal) Retail Insight Notifications'			-- Leave Retail Insight Notifications
,		@acc_desc nvarchar(256) 				= '712466-DB21(Internal) Mandrill Mail'			-- E.g: KC_Production
,		@prf_desc nvarchar(256) 				= '(Internal) Mandrill Mail Profile'				-- E.g: KC_Production
	

-- Mandrill settings

,		@mailserver_type sysname				= 'SMTP'
,		@port int								= '587'
,		@username nvarchar(128)					= 'techops@retailinsight.co.uk'
,		@password nvarchar(128)					= 'X7YPW8-X1Hr4RsQwyjCfzg'
,		@use_default_credentials sysname		=  0 
,		@enable_ssl	bit							=  1 

,		@profile_name sysname 					= 'Internal'								-- E.g: DB12 KC_PRD Database Mail or Internal if for internal purposes

,		@email nvarchar(128)					= '712466-DB21@retailinsight.co.uk'				-- Must remain the same
,		@replyto_address nvarchar(128)			= 'noreply@retailinsight.co.uk'						-- Must remain the same
,		@mailserver_name sysname				= 'smtp.mandrillapp.com'							-- Must remain the same


-- Create a Database Mail profile
IF NOT EXISTS(SELECT * FROM	msdb..sysmail_profile WHERE name = @profile_name)
	BEGIN
	 EXECUTE msdb.dbo.sysmail_add_profile_sp
	  @profile_name = @profile_name,
	  @description  = @prf_desc;
	END	-- IF EXISTS profile


-- Create a Database Mail account
IF NOT EXISTS(SELECT * FROM msdb..sysmail_account WHERE name =  @account_name)
	BEGIN
	 EXECUTE msdb.dbo.sysmail_add_account_sp
	  @account_name            = @account_name,
	  @email_address           = @email,
	  @display_name            = @displayname,
	  @replyto_address         = @replyto_address,
	  @description             = @acc_desc,
	  @mailserver_name         = @mailserver_name,
	  @mailserver_type         = @mailserver_type,
	  @port                    = @port,
	  @username                = @username,
	  @password                = @password,
	  @use_default_credentials =  0 ,
	  @enable_ssl              =  1 ;
	END -- IF EXISTS account


	 
-- Associate account to profile
IF NOT EXISTS(SELECT * FROM msdb..sysmail_profileaccount pa 
  			   INNER JOIN msdb..sysmail_profile p ON pa.profile_id = p.profile_id
  			   INNER JOIN msdb..sysmail_account a ON pa.account_id = a.account_id
  			    WHERE	p.name = @profile_name
  			    AND		a.name = @account_name)
 BEGIN
 EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @profile_name,
    @account_name = @account_name,
    @sequence_number = 1;
 END -- IF EXISTS associate account to profile

  
-- Grant access to the profile to all msdb database users
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = @profile_name,
    @principal_name = 'public',
    @is_default = 0;

 
EXECUTE msdb.dbo.sp_set_sqlagent_properties 
	@email_save_in_sent_folder=1, 
	@databasemail_profile=@profile_name, 
	@use_databasemail=1
GO

-- Pre-SQL2012 version
--EXECUTE msdb.dbo.sp_set_sqlagent_properties 
--	@email_save_in_sent_folder=1, 
--	email_profile= N'APP4$JDE2012 Mandrill', 
--	@use_databasemail=1
--GO




-- ********************************
-- Send a test email
-- ********************************

 DECLARE @test_profile sysname
 SELECT TOP 1 @test_profile = name FROM msdb..sysmail_profile ORDER BY last_mod_datetime desc
 SELECT @test_profile

EXECUTE msdb.dbo.sp_send_dbmail
	@profile_name = @test_profile,
    @subject =		'Test Database Mail Message',
    @recipients =	'hantochow@retailinsight.co.uk',
    @query =		'SELECT @@SERVERNAME';
GO

SELECT * FROM msdb..sysmail_profile

--==================
--Troubleshooting
--==================
select * from msdb.dbo.sysmail_allitems
ORDER BY send_request_date desc



 SELECT  * FROM msdb..sysmail_profile ORDER BY last_mod_datetime



SELECT is_broker_enabled FROM sys.databases WHERE name = 'msdb'
--Check to see if Database Mail is started in the msdb database:

EXECUTE msdb.dbo.sysmail_help_status_sp
--…and start Database Mail if necessary:

EXECUTE msdb.dbo.sysmail_start_sp
--Check the status of the mail queue:

EXECUTE msdb.dbo.sysmail_help_queue_sp @queue_type = 'Mail'
--Check the Database Mail event logs:

SELECT * FROM msdb.dbo.sysmail_event_log
--Check the mail queue for the status of all items (including sent mails):

SELECT * FROM msdb.dbo.sysmail_allitems


 select 
  err.[description] ,
  fail.*
FROM [msdb].[dbo].[sysmail_event_log] err
  inner join [msdb].dbo.sysmail_faileditems fail
    On err.mailitem_id = fail.mailitem_id 


