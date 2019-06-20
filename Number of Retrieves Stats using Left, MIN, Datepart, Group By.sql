/*** Script for generating aggregate statistics by Week for Retrievals based on specific criteria and a set begin date

	 Created by: Christopher Wilbar
	 Version 1.1 - 6-20-19 - restructured using DATEPART
***/ 	

declare @begindate varchar(10) =  '2019-01-01'

SELECT
	DATEPART(WEEK, dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))) as Week_Number
	,LEFT(MIN(dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))),12) as Week_Of
    ,count(distinct Identifier) as Number_Of_Studies_Retrieved
FROM 
	mvf.dbo.map_event
WHERE 
	1=1
	and dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101')) > @begindate  
	and EVENT_TYPE = 'RETRIEVE'
	and EVENT_CLASS != 'ERROR' 
	--and [USER_ID] = 'service'
GROUP BY DATEPART(WEEK, dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101')))
ORDER BY Week_Number 


SELECT
	DATEPART(WEEK, dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))) as Week_Number
	,LEFT(MIN(dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))),12) as Week_Of
	,[USER_ID]_
    ,count(distinct Identifier) as Number_Of_Studies_Retrieved
FROM 
	mvf.dbo.map_event
WHERE 
	1=1
	and dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101')) > @begindate  
	and EVENT_TYPE = 'RETRIEVE'
	and EVENT_CLASS != 'ERROR' 
	--and [USER_ID] = 'service'
GROUP BY DATEPART(WEEK, dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))), [USER_ID]
ORDER BY Week_Number 

