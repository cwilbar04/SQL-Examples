/****** Script for data mining and then aggregating statistics, adjusting for Epoch and UTC Time.

	Created By: Christopher Wilbar
	Version 1.1 - 6-20-2019 - table/db names changed
******/
SELECT [HOST]
      ,dateadd(hh,-5,dateadd(s,[DATE_TIME_CREATED],'19700101')) as dtcreated
      ,[USER_ID]
      ,[EVENT_CLASS]
      ,[EVENT_TYPE]
      ,[EVENT_INDEX]
      ,[EVENT_LEVEL]
      ,[OBJECT_CLASS]
      ,[OBJECT_TYPE]
      ,[OBJECT_REF]
      ,[IDENTIFIER]
      ,[SOURCE]
      ,[DESTINATION]
      ,[NUM_OBJECTS]
      ,[QUANTITY]
      ,[ELAPSED_TIME]
      ,[EVENT_INFO]
      ,[VIEWED]
      ,[JOB_ID]
      ,[JOB_ISSUER_ID]
  FROM 
		[database1].[dbo].[MAP_EVENT] a 
  where destination = 'CARD_QR'
		 and EVENT_TYPE = 'RETRIEVE'	
		 and ELAPSED_TIME > 1
		 and dateadd(hh,-5,dateadd(s,[DATE_TIME_CREATED],'19700101')) > '2018-06-29'
		 and IDENTIFIER not in ('4943230193','4975499341')
  order by 
		DATE_TIME_CREATED desc



select 
	EVENT_TYPE,
	min(dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))) as starttime,
	max(dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))) as endtime,
	count(object_ref) as number_of_studies,
	avg(elapsed_time) as average_time
from
	[database1].[dbo].[MAP_EVENT]  
  where ((destination = 'CARD_QR' and EVENT_TYPE = 'RETRIEVE') OR
		(DESTINATION = 'CARD' and EVENT_TYPE = 'STORE'))	
		 and ELAPSED_TIME > 1
		 and dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101')) BETWEEN '2018-01-01' and '2019-02-15'
		and EVENT_CLASS != 'ERROR'
  group by EVENT_TYPE
union
select 
	EVENT_TYPE,
	min(dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))) as starttime,
	max(dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))) as endtime,
	count(object_ref) as number_of_studies,
	avg(elapsed_time) as average_time
from
	[database1].[dbo].[MAP_EVENT]  
  where ((destination = 'CARD_QR' and EVENT_TYPE = 'RETRIEVE') OR
		(DESTINATION = 'CARD' and EVENT_TYPE = 'STORE'))	
		 and ELAPSED_TIME > 1
		 and dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101')) > '2019-02-23 04:00:00.000'
		and EVENT_CLASS != 'ERROR'
 group by EVENT_TYPE

select
		sum(case when event_class = 'AUDIT' then 1 else 0 end) as Audit_Count
		,sum(case when event_class = 'ERROR' then 1 else 0 end) as Error_Count
		,sum(case when event_class = 'ERROR' then 1 else 0 end)*100./(sum(case when event_class = 'ERROR' then 1 else 0 end)+sum(case when event_class = 'AUDIT' then 1 else 0 end))
from database1.dbo.MAP_EVENT
where destination = 'CARD_QR'
		 and EVENT_TYPE = 'RETRIEVE'	
		 and ELAPSED_TIME > 1
		 and dateadd(hh,-5,dateadd(s,[DATE_TIME_CREATED],'19700101')) > '2018-07-13'


