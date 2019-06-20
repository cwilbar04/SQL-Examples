/* Script for loading comma separated txt file with info from separate database and comparing to current system. 
   Database/table names obscured to avoid sharing any proprietary information.

   Created by: Christopher Wilbar
   Version 1.1 (obfuscated version) - 06-17-2019
*/


IF OBJECT_ID('tempdb..#pacs1uid') IS NOT NULL
    DROP TABLE #pacs1uid

create table #pacs1uid
	(patname nvarchar(256),
	 patID nvarchar(64),
	 suid nvarchar(64),
	 seriesuid nvarchar(64),
	 studydate nvarchar(14),
	 modal nvarchar(16),
	 num_series int NULL,
	 num_object_series int NULL,
	 num_objects_study int NULL, 
	 formatdbkey int NULL,
	 storagelocdbkey int NULL,
	 dicomstudyid nvarchar(64),
	 StudyDescription nvarchar(200)
	 )

bulk insert #pacs1uid 
from 'C:\temp\pacs1seriesfull05082019.txt'	
with (FIELDTERMINATOR =',',rowterminator='\n',firstrow=1, DATAFILETYPE='widechar')

--select * from #pacs1uid

SELECT 
RTRIM(ISNULL(PATIENT_ID,'MISSING')) as PATIENT_ID_PACS2
,RTRIM(ISNULL(patID,'MISSING')) as patID_PACS1
,RTRIM(ISNULL(ACCESSION_NUMBER,'MISSING')) as ACCESSION_NUMBER_PACS2
,RTRIM(ISNULL(STUDY_UID,'MISSING')) as STUDY_UID_PACS2
,RTRIM(ISNULL(suid,'MISSING')) as suid_PACS1
,RTRIM(ISNULL(SERIES_UID,'MISSING')) as SERIES_UID_PACS2
,RTRIM(ISNULL(seriesuid,'MISSING')) as seriesuid_PACS1
,RTRIM(ISNULL(STUDY_DATE,'MISSING')) as STUDY_DATE_PACS2
,RTRIM(ISNULL(left(studydate,10),'MISSING')) as studydate_PACS1
,RTRIM(case when NUM_SERIES_PACS2 is NULL then 0 else NUM_SERIES_PACS2 end) as NUM_SERIES_PACS2
,RTRIM(ISNULL(num_series,0)) as num_series_PACS1
,RTRIM(case when secount.NUM_OBJECT_SERIES_PACS2 is NULL then 0 else secount.NUM_OBJECT_SERIES_PACS2 end) as NUM_OBJECT_SERIES_PACS2
,RTRIM(ISNULL(num_object_series,0)) as num_object_series_PACS1
,RTRIM(case when b.NUM_OBJECTS is NULL then 0 else b.NUM_OBJECTS end) as NUM_OBJECTS_STUDY_PACS2
,RTRIM(ISNULL(x.num_objects_study,0)) as num_objects_study_PACS1
,RTRIM(case when b.NUM_OBJECTS is NULL then x.num_objects_study else x.num_objects_study - b.NUM_OBJECTS end) as Missing_pacs1_pacs2
,RTRIM(ISNULL(INSTITUTIONAL_DEPARTMENT_NAME,'MISSING')) as INSTITUTIONAL_DEPARTMENT_NAME_PACS2
,RTRIM(ISNULL(SOURCE_CALLING_TITLE,'MISSING')) as SOURCE_CALLING_TITLE_PACS2
,RTRIM(ISNULL(b.STATION_NAME,'MISSING')) as STATION_NAME_PACS2
,RTRIM(ISNULL(STUDY_DESCRIPTION,'MISSING')) as STUDY_DESCRIPTION_PACS2
,RTRIM(ISNULL(b.MODALITY,'MISSING')) as MODALITY_PACS2
,RTRIM(ISNULL(modal,'MISSING')) as modality_PACS1
,RTRIM(ISNULL(PATIENT_NAME,'MISSING')) as PATIENT_NAME_PACS2
,RTRIM(ISNULL(patname,'MISSING')) as patient_name_PACS1
,formatdbkey_PACS1
,storagelocdbkey_PACS1
,RTRIM(ISNULL(dicomstudyid,'MISSING')) as dicomstudyid_PACS1
  FROM #pacs1uid x 
--	left join [database].[dbo].[STUDY] b on x.suid = b.STUDY_UID
	left join [database].[dbo].[SERIES] a on a.SERIES_UID = x.seriesuid
	left join [database].[dbo].[STUDY] b on b.STUDY_REF = a.STUDY_REF
	left join (select se.SERIES_REF, count(*) as NUM_OBJECT_SERIES_PACS2 from [database].[dbo].series se join [database].[dbo].OBJECT o on se.SERIES_REF = o.SERIES_REF group by se.series_ref) secount on secount.SERIES_REF = a.SERIES_REF 
	left join (select st.study_ref, count(*) as NUM_SERIES_PACS2 from [database].[dbo].study st join [database].[dbo].SERIES se on st.STUDY_REF = se.STUDY_REF group by st.study_ref) numse on numse.STUDY_REF = b.STUDY_REF

IF OBJECT_ID('tempdb..#pacs1uid') IS NOT NULL
    DROP TABLE #pacs1uid