/* Collection of useful snippets from code to reference when needed */

-- Working with temp tables

if object_id('tempdb..##temptable') is not Null
begin
	drop table ##temptable;
end;

create table ##temptable(
	col1 varchar(80) NOT NULL PRIMARY KEY,
	col2 int NULL
	)

insert into ##temptable (

)

--Remove whitespace and commas, replace missing with specific text

LTRIM(RTRIM(ISNULL(REPLACE(COLUMN,',',''),'MISSING'))) as COLUMN

--Pad Digits to Result
RIGHT(LTRIM(RTRIM('000000000000' + ISNULL(REPLACE(COLUMN,',',''),'MISSING'))),12) as COLUMN



-- Convert from Epoch Time **Need to adjust for Daylight Savings Time. Have not found a good way to automatically do this
dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101')))

-- Convert datetime to yyyymmdd
CONVERT(varchar(8), GETDATE(), 112) 



--Summarize data by Week
insert into ##temptable
	select distinct
		IDENTIFIER
		,[USER_ID]
		,datediff(week,'2019-01-06', dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))) as weeknumber --First Sunday of the Year
	from mvf.dbo.map_event
	where 
	1=1
	and datediff(week,'2019-01-06', dateadd(hh,-6,dateadd(s,[DATE_TIME_CREATED],'19700101'))) > 0  
	and EVENT_TYPE = 'RETRIEVE'
	and EVENT_CLASS != 'ERROR' 
	--and [USER_ID] = 'service'

select  
convert(date,dateadd(week, weeknumber,'2019-01-06')) as Week_Of
,count(weeknumber) as Number_Of_Studies
from ##temptable
group by 
weeknumber
order by 
week_of asc


