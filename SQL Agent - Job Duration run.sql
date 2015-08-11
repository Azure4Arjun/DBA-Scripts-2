
USE msdb

SELECT * FROM	dbo.sysjobs j
SELECT * FROM	dbo.sysjobactivity
SELECT * FROM	dbo.sysjobhistory


SELECT  j.name 
,		h.step_name
,		h.step_id
,		dbo.agent_datetime(h.run_date, h.run_time) AS [RunDateTime]
,		((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60)   as [RunDurationMinutes]
FROM	dbo.sysjobs j
JOIN	dbo.sysjobhistory h ON j.job_id = h.job_id
WHERE	step_id <> 0
ORDER BY [RunDurationMinutes] desc
