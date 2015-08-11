

/*	
	sys.dm_exec_query_memory_grants
	Check which query is next to be picked up by running the following query. 
	If the returns no rows, then there are no waiting queries. 
*/

SELECT  g.session_id
,		DB_NAME(p.[dbid])
,		OBJECT_NAME(p.[objectid])
,		g.dop
,		g.request_time
,		g.grant_time
,		g.required_memory_kb
,		g.used_memory_kb
,		g.max_used_memory_kb
,		g.ideal_memory_kb
,		g.query_cost
,		g.timeout_sec
,		p.query_plan
,		t.[text]
FROM	sys.dm_exec_query_memory_grants g
CROSS APPLY sys.dm_exec_query_plan(g.plan_handle) p
CROSS APPLY sys.dm_exec_sql_text(g.plan_handle) t
