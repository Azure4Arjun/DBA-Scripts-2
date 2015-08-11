
/* 	
	Show sent emails and attachements 
	for a particular email address

*/

DECLARE @RecipientEmail nvarchar(50) = 'daldred%'

SELECT  m.sent_date
,		m.recipients
,		m.subject
,		m.body
,		m.file_attachments
,		m.sent_status
,		a.filesize
FROM	msdb..sysmail_allitems m
JOIN	msdb..sysmail_mailattachments a ON m.mailitem_id = a.mailitem_id
WHERE m.recipients like @RecipientEmail
ORDER BY m.sent_date desc

