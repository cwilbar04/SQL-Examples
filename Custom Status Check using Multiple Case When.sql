/*Script to check custom defined Status of Studies in PACS system based on PatientID.
  Used to track when Studies have been completely sent in to System and Ready to Be Transferred Elsewhere.
  Additional Script checks for other relevant studies with a PatientID that was not initially identified so that it can be added to the temptable list.

  database/table names changed to avoid sharing any proprietary information.
   Created by: Christopher Wilbar
   Version 1.1 (database/table name changed version) - 06-17-2019
*/


if object_id('tempdb..##temptable') is not Null
begin
	drop table ##temptable;
end;

create table ##temptable(
	patientID varchar(12) NOT NULL PRIMARY KEY
	);
	
insert into ##temptable (patientID)
values ('patientid')
;

SELECT
	case when e.NUM_OBJECTS = s.NUM_OBJECTS and f.EVENT_TYPE = 'SEND' then '3_successful_send' else
	case when e.NUM_OBJECTS is not NULL and ((e.NUM_OBJECTS != s.NUM_OBJECTS and f.EVENT_TYPE = 'SEND') or (f.EVENT_CLASS = 'ERROR')) then '0_RESEND_PARTIAL_SEND' else
	case when e.NUM_OBJECTS is not NULL and f.EVENT_TYPE is NULL then '0_Currently_Being_Sent' else
	case when e.NUM_OBJECTS is NULL and DATE_TIME_CLOSED > 0 and datediff(MINUTE,dateadd(hh,-5,dateadd(s,[DATE_TIME_MODIFIED],'19700101')),getdate()) > 10 then '1_READY_TO_SEND' else
	case when e.NUM_OBJECTS is NULL and (DATE_TIME_CLOSED = 0 or datediff(MINUTE,dateadd(hh,-5,dateadd(s,[DATE_TIME_MODIFIED],'19700101')),getdate()) <= 10) then '2_In_Process_Prepare_To_Send' else
	case when e.NUM_OBJECTS is NULL and s.NUM_OBJECTS is NULL then '0_not_yet_completed'
	end end end end end end as 'Status'
    ,id.patientID
    ,[PATIENT_NAME]
	,[ACCESSION_NUMBER]
	,s.[NUM_OBJECTS] as Study_Objects
	,e.NUM_OBJECTS as Sent_Objects
	,STUDY_STATUS_ID
    ,[STUDY_DATE] + ' ' + [STUDY_TIME] as STUDY_DATE_TIME
	,[STUDY_DESCRIPTION]  
    ,[REFERRING_PHYSICIAN]
    ,[REQUESTING_PHYSICIAN]
    ,[STATION_NAME]
    ,[SOURCE_CALLING_TITLE]
	,[STUDY_REF]
FROM 
	##temptable id
	left join [database1].[dbo].[STUDY] s on id.patientID = s.PATIENT_ID and STUDY_DATE > '20190202'
	left join (select identifier, max(NUM_OBJECTS) as NUM_OBJECTS from database1.dbo.MAP_EVENT where EVENT_TYPE = 'STUDY_SENT' and DESTINATION = 'NBA175B' group by IDENTIFIER) e on s.ACCESSION_NUMBER = e.IDENTIFIER 
	left join (select identifier, event_type, EVENT_CLASS, max(date_time_created) as dt from database1.dbo.MAP_EVENT where EVENT_TYPE = 'SEND' and DESTINATION = 'NBA175B' group by identifier, event_type, EVENT_CLASS) f on s.ACCESSION_NUMBER = f.IDENTIFIER 
ORDER BY 'Status', STUDY_STATUS_ID 


SELECT 
	 PATIENT_ID
	,PATIENT_NAME
	,STUDY_DATE
	,STUDY_DESCRIPTION
FROM 
	database1.dbo.STUDY
WHERE 
	REFERRING_PHYSICIAN = 'physician' 
	and PATIENT_ID not in (select patientID from ##temptable) 
	and STUDY_DATE > 20190202
	and INSTITUTIONAL_DEPARTMENT_NAME = 'ECHO'

/*
SELECT
	patientID
	,getdate()
	,dateadd(s,[DATE_TIME_MODIFIED],'19700101')
	,datediff(MINUTE,dateadd(hh,-5,dateadd(s,[DATE_TIME_MODIFIED],'19700101')),getdate()) 
FROM 
	##temptable id
	left join [database1].[dbo].[STUDY] s on id.patientID = s.PATIENT_ID and STUDY_DATE > '20190202'
	left join database1.dbo.MAP_EVENT e on s.ACCESSION_NUMBER = e.IDENTIFIER and EVENT_TYPE = 'STUDY_SENT' and DESTINATION = 'NBA175B'
	left join database1.dbo.MAP_EVENT f on s.ACCESSION_NUMBER = f.IDENTIFIER and f.EVENT_TYPE = 'SEND' and f.DESTINATION = 'NBA175B'  
 -- ORDER BY 'Status' asc
 */

if object_id('tempdb..##temptable') is not Null
begin
	drop table ##temptable;
end;

