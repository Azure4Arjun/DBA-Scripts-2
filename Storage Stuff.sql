

-- Cehck location of the rows, pages on files
SELECT sys.fn_PhysLocFormatter(%%physloc%%), *
FROM [msdb].[dbo].[sysmail_account]


