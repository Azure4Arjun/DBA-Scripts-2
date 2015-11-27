


SELECT @@SERVERNAME


-- check what profiles are available:

SELECT p.profile_id
,		p.name				AS ProfileName
,		p.description		AS ProfileDesc
,		a.account_id	
,		a.name				AS AccountName	
,		a.description		AS AccountDesc
,		a.email_address
,		a.display_name
,		a.replyto_address
,		s.servertype 
,		s.servername
,		s.port
,		s.username
,		s.enable_ssl
FROM msdb..sysmail_profileaccount pa
JOIN msdb..sysmail_profile p ON pa.profile_id = p.profile_id
JOIN msdb..sysmail_account a ON pa.account_id = a.account_id
JOIN msdb..sysmail_server s ON a.account_id = s.account_id



----

   
DECLARE  @vaccount_name sysname
		,@vdescription nvarchar(256)
		,@vemail_address nvarchar(128)
		,@vdisplay_name nvarchar(128)
		,@vreplyto_address nvarchar(128)


SELECT	@vaccount_name  = a.name		
,		@vdescription  = a.[description]
,		@vemail_address = a.email_address
,		@vdisplay_name  = a.display_name
,		@vreplyto_address  = a.replyto_address
FROM	msdb..sysmail_profileaccount pa
JOIN	msdb..sysmail_profile p ON pa.profile_id = p.profile_id
JOIN	msdb..sysmail_account a ON pa.account_id = a.account_id
WHERE	1=1 
AND		p.name = 'DB9 SQL2014_3  Mandrill'
-- AND		p.NAME = 'Internal'				-- for internal profiles



SELECT @vaccount_name  
,	   @vdescription  
,	   @vemail_address 
,	   @vdisplay_name  
,	   @vreplyto_address 



-- Public
EXECUTE msdb.dbo.sysmail_update_account_sp
     @account_name = @vaccount_name
    ,@description =  @vdescription
    ,@email_address = @vemail_address 
    ,@display_name = @vdisplay_name  
    ,@replyto_address = @vreplyto_address 
    ,@mailserver_name = 'smtp.mandrillapp.com'
    ,@mailserver_type = 'SMTP'
    ,@port = 587
    ,@timeout = 600
    ,@username = 'techops@retailinsight.co.uk'
    ,@password = 'eFfAATBABDqayLUJyW2H7A'
    ,@use_default_credentials = 0
    ,@enable_ssl = 1;




-- Public

-- Test



-- ********************************
-- Send a test email
-- ********************************

 DECLARE @profile sysname
 ,		@server_name sysname  = @@SERVERNAME
 ,		@vSubject	NVARCHAR(4000)
 ,		@vquery		NVARCHAR(4000)

 SELECT TOP 1 @profile = name 
 FROM msdb..sysmail_profile 
 --WHERE name = 'Internal'
 ORDER BY last_mod_datetime asc

SELECT @profile
 
SET @vSubject = 'Test DatabaseMail message from: '+ @server_name;
SET  @vquery = 'Sent from ' + @server_name + '. Using profile: ' + @profile;


EXECUTE msdb.dbo.sp_send_dbmail
	@profile_name = @profile,
    @subject =		@vSubject,
    @recipients =	'hantochow@retailinsight.co.uk',
    @Body =			@vquery
GO


-- Troubleshooting
select * from msdb.dbo.sysmail_allitems ORDER BY send_request_date desc






--#################################################################################################
-- Mail Settings Internal
--#################################################################################################
IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'Internal') 
  BEGIN
    --CREATE Profile [Internal]
    EXECUTE msdb.dbo.sysmail_add_profile_sp
      @profile_name = 'Internal',
      @description  = 'Using local SMTP Server';
  END --IF EXISTS profile
 

DECLARE @vemail_address	NVARCHAR(500) =  @@ServerName + '@retailinsight.co.uk'
,		@vdisplay_name	NVARCHAR(500) = @@ServerName + ' SQL Server'
,		@vdescription	NVARCHAR(500) = @@Servername + ' SQL Server'

-- Possible correction from \ to $
SET @vemail_address = REPLACE(@vemail_address,'\','$')
SET	@vdisplay_name	= REPLACE(@vdisplay_name,'\','$')
SET	@vdescription	= REPLACE(@vdescription,'\','$')


SELECT	@vemail_address 
,		@vdisplay_name	
,		@vdescription	


  IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE  name = 'Internal')
  BEGIN
    --CREATE Account [Internal]
    EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name            = 'Internal',
    @email_address           = @vemail_address,
    @display_name            = @vdisplay_name,
    @replyto_address         = 'noreply@retailinsight.co.uk',
    @description             = @vdescription,
    @mailserver_name         = 'LOCALHOST',
    @mailserver_type         = 'SMTP',
    @port                    = '25',
    @username                =  NULL ,
    @password                =  NULL , 
    @use_default_credentials =  0 ,
    @enable_ssl              =  0 ;
  END --IF EXISTS  account
  
IF NOT EXISTS(SELECT *
              FROM msdb.dbo.sysmail_profileaccount pa
                INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id
                INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id  
              WHERE p.name = 'Internal'
                AND a.name = 'Internal') 
  BEGIN
    -- Associate Account [Internal] to Profile [Internal]
    EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
      @profile_name = 'Internal',
      @account_name = 'Internal',
      @sequence_number = 1 ;
  END --IF EXISTS associate accounts to profiles

 
 --DB19
--Internal
--DB19Mail
--DB19 Mandrill


 
  ----

   
DECLARE  @vaccount_name sysname
		,@vdescription nvarchar(256)
		,@vemail_address nvarchar(128)
		,@vdisplay_name nvarchar(128)
		,@vreplyto_address nvarchar(128)


SELECT	@vaccount_name  = a.name		
,		@vdescription  = a.[description]
,		@vemail_address = a.email_address
,		@vdisplay_name  = a.display_name
,		@vreplyto_address  = a.replyto_address
FROM	msdb..sysmail_profileaccount pa
JOIN	msdb..sysmail_profile p ON pa.profile_id = p.profile_id
JOIN	msdb..sysmail_account a ON pa.account_id = a.account_id
WHERE	1=1 
AND		p.name = 'Internal'
-- AND		p.NAME = 'Internal'				-- for internal profiles



SELECT @vaccount_name  
,	   @vdescription  
,	   @vemail_address 
,	   @vdisplay_name  
,	   @vreplyto_address 



-- Public
EXECUTE msdb.dbo.sysmail_update_account_sp
     @account_name = @vaccount_name
    ,@description =  @vdescription
    ,@email_address = @vemail_address 
    ,@display_name = @vdisplay_name  
    ,@replyto_address = @vreplyto_address 
    ,@mailserver_name = 'LOCALHOST'
    ,@mailserver_type = 'SMTP'
    ,@port = 25
    ,@timeout = 600
    ,@username = NULL
    ,@password = NULL
    ,@use_default_credentials = 0
    ,@enable_ssl = 0;



EXECUTE msdb.dbo.sysmail_update_account_sp
	 @account_id = 2
     ,@account_name = '690670-DB9$SQL2014(Internal)'
    --,@email_address = '712465-APP4$KC@retailinsight.co.uk'
    ,@description =  '690670-DB9$SQL2014(Internal)'
    ,@mailserver_name = 'LOCALHOST'
    ,@mailserver_type = 'SMTP'
    ,@port = 25
    ,@timeout = 600
    ,@username = NULL
    ,@password = NULL
    ,@use_default_credentials = 0
    ,@enable_ssl = 0;








-- ********************************
-- Send a test email
-- ********************************

 DECLARE @profile sysname
 ,		@server_name sysname  = @@SERVERNAME
 ,		@vSubject	NVARCHAR(4000)
 ,		@vquery		NVARCHAR(4000)

 SELECT TOP 1 @profile = name 
 FROM msdb..sysmail_profile 
 WHERE name = 'Internal'
 ORDER BY last_mod_datetime --desc

 
--DB16
--Internal


SET @vSubject = 'Test DatabaseMail message from: '+ @server_name;
SET  @vquery = 'Sent from ' + @server_name + '. Using profile: ' + @profile;

IF @profile IS NOT NULL
BEGIN
		EXECUTE msdb.dbo.sp_send_dbmail
		@profile_name = @profile,
		@subject =		@vSubject,
		@recipients =	'hantochow@retailinsight.co.uk',
		@Body =			@vquery
END
ELSE
	PRINT '!!! No Internal profile configured !!!' 







-- Manual test
EXECUTE msdb.dbo.sp_send_dbmail
		@profile_name = 'Internal',
		@subject =		'Test Internal Profile',
		@recipients =	'hantochow@retailinsight.co.uk',
		@Body =			'Internal'




-- Troubleshooting
select * from msdb.dbo.sysmail_allitems ORDER BY send_request_date desc


 select 
  err.[description] ,
  fail.*
FROM [msdb].[dbo].[sysmail_event_log] err
  inner join [msdb].dbo.sysmail_faileditems fail
    On err.mailitem_id = fail.mailitem_id 
ORDER BY fail.sent_date DESC

