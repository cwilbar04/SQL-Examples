/****** 
Script for collecting aggregate statisitics for Retrieval Data. Relevant data is first extracted in to a temp table so that different statisics can be manipulated more easily.


  database/table names changed to avoid sharing any proprietary information.
   Created by: Christopher Wilbar
   Version 1.1 (database/table name changed version) - 06-19-2019
******/

declare @startdate varchar(10) = '2019-01-01'
declare @enddate varchar(10) = convert(varchar(10),getdate(),23)

if object_id('tempdb..##RetrieveData') is not Null
begin
	drop table ##RetrieveData;
end;

create table ##RetrieveData(
	[JOB_REF] int not null
	,[IDENTIFIER] varchar(64) not null
	,[RETRIEVAL_DATE] datetime not null
	,[NUMBER_OF_IMAGES] int not null
	,[SECONDS_TO_COMPLETE] int not null
	,[SECONDS_TO_WAIT] int  null
	,[SECONDS_TO_RETRIEVE] int  null
	,[RETRIES] int null
	);

insert into ##RetrieveData
	select 
		job_ref
		,IDENTIFIER
		,max([Timestamp]) as datecomplete
		,max(REMAINING) as numberofimages
		,datediff(second,min([Timestamp]),max([Timestamp])) as timetook
		,datediff(second,min(case when [STATUS] = 'NEW' then [Timestamp] end),min(case when [STATUS] = 'PROGRESS' then [Timestamp] end)) as timetowait
		,datediff(second,min(case when [STATUS] = 'PROGRESS' then [Timestamp] end),max(case when [STATUS] = 'PROGRESS' then [Timestamp] end)) as timetoretrieve
		,sum(case when [STATUS] = 'RETRY' then 1 else 0 end)/2 as retries
	FROM 
		[database1].[dbo].[JOB_Logging]
	group by 
		job_ref, [TYPE], [IDENTIFIER]
	having 
		[TYPE] = 'RETRIEVE'
	--	and datediff(second,min([Timestamp]),max([Timestamp])) > 1
		and sum([Completed]) > 0 --Images actually retrieved
	    and job_ref != '1851508' --Large outlier
	--	and IDENTIFIER not in ('1','2') -- No images
	--	and IDENTIFIER not in (select IDENTIFIER from [database1].[dbo].[EVENT] where [Event_Class] ='ERROR' and event_type ='RETRIEVE')
	--	and max([Timestamp]) > '2018-07-13'
		and max(REMAINING) > 1
		and max([Timestamp]) not between '2018-07-16 10:50:00.000' and '2018-07-16 11:55:00.000' --Acuo app issue unrelated to Syngo. Isolating to normal operations
	--	and sum(case when [STATUS] = 'RETRY' then 1 else 0 end) > 0
		
	;

select * from ##RetrieveData order by RETRIEVAL_DATE desc;

select
	min(Retrieval_Date) as begintime
	,max(Retrieval_Date) as endtime
	,count(job_ref) as number_of_studies
	,sum(case when RETRIES > 0 then 1 else 0 end) as number_of_retries
	,avg([SECONDS_TO_COMPLETE]) as average_seconds
	,min([SECONDS_TO_COMPLETE]) as mintime
	,max([SECONDS_TO_COMPLETE]) as maxtime
	,avg([SECONDS_TO_WAIT]) as average_wait_time
	,avg([SECONDS_TO_RETRIEVE]) as average_retrieve_time 
from 
	##RetrieveData
where
	Retrieval_Date BETWEEN @startdate and @enddate
;

if object_id('tempdb..##RetrieveData') is not Null
begin
	drop table ##RetrieveData;
end;

---/*
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
		[database1].[dbo].[EVENT]
  WHERE
		[Event_Class] ='ERROR' and event_type ='RETRIEVE'		
		--Identifier = '1'
  ORDER BY dtcreated desc

select * from database1.dbo.JOB_Logging where Identifier = '1' order by [timestamp] asc
--*/