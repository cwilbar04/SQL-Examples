/* Script for loading tab delimited txt file with info from separate databases and comparing to current VNA system. 
   Outputs studies stored twice (two deparate databases) and also outputs rows 
   Database/table names obscured to avoid sharing any proprietary information.

   Created by: Christopher Wilbar
   Version 1.1 (obfuscated version) - 06-17-2019
*/


IF OBJECT_ID('tempdb..#pacs1andpacs2uid') IS NOT NULL
    DROP TABLE #pacs1andpacs2uid


create table #pacs1andpacs2uid
	(PATIENT_ID_PACS2 varchar(64),
	 patID_PACS1 varchar(64),
	 ACCESSION_NUMBER_PACS2 varchar(16),
	 STUDY_UID_PACS2 varchar(64),
	 suid_PACS1 varchar(64),
	 SERIES_UID_PACS2 varchar(64),
	 seriesuid_PACS1 varchar(64),
	 STUDY_DATE_PACS2 varchar(10),
	 studydate_PACS1 varchar(14),
	 NUM_SERIES_PACS2 int,
	 num_series_PACS1 int,
	 NUM_OBJECT_SERIES_PACS2 int,
	 num_object_series_PACS1 int,
	 NUM_OBJECTS_STUDY_PACS2 int,
	 num_objects_study_PACS1 int,
	 Missing_pacs1_pacs2 int,
	 INSTITUTIONAL_DEPARTMENT_NAME_PACS2 varchar(64),
	 SOURCE_CALLING_TITLE_PACS2 varchar(16),
	 STATION_NAME_PACS2 varchar(16),
	 STUDY_DESCRIPTION_PACS2 varchar(64),
	 MODALITY_PACS2 varchar(16),
	 modality_PACS1 varchar(16),
	 PATIENT_NAME_PACS2 varchar(200)
	 )

bulk insert #pacs1andpacs2uid 
from 'C:\temp\pacs1seriesfull.txt'	
with (FIELDTERMINATOR ='\t',rowterminator='\n',firstrow=2)

select * 
	from #pacs1andpacs2uid a 
		join [CARD_PUB].dbo.T_Series b on a.seriesuid_PACS1 = b.SE_DICOM_UID
		join [CARD_MIG_PUB].dbo.T_Series c on a.seriesuid_PACS1 = c.SE_DICOM_UID
	where 
		b.SE_DICOM_UID = c.SE_DICOM_UID

SELECT  
	'CARD_PUB' as DB 
	 ,PATIENT_ID_PACS2 
	 ,patID_PACS1
	 ,ST_PATIENT_ID as ST_PATIENT_ID_VNA
	 ,ACCESSION_NUMBER_PACS2
	 ,ST_ACCESSIONNUMBER as ST_ACCESSIONNUMBER_VNA
	 ,STUDY_UID_PACS2
	 ,suid_PACS1
	 ,st.ST_DICOM_UID as st.ST_DICOM_UID_VNA
	 ,case when STUDY_UID_PACS2 = suid_PACS1_PACS1 and suid_PACS1_PACS1 = st.ST_DICOM_UID then 'MATCH' else 'NO MATCH' end as ALL_MATCH
	 ,case when STUDY_UID_PACS2 = suid_PACS1_PACS1 then 'MATCH' else 'NO MATCH' end as pacs2_pacs1_MATCH
	 ,case when suid_PACS1 = st.ST_DICOM_UID then 'MATCH' else 'NO MATCH' end as pacs1_VNA_MATCH 
	 ,case when STUDY_UID_PACS2 = st.ST_DICOM_UID then 'MATCH' else 'NO MATCH' end as pacs2_VNA_MATCH
	 ,SERIES_UID_PACS2
	 ,seriesuid_PACS1
	 ,se.SE_DICOM_UID as se.SE_DICOM_UID_VNA
	 ,STUDY_DATE_PACS2
	 ,left(studydate_PACS1,8) as studydate_PACS1
	 ,Format(ST_DATE, N'yyyyMMdd') as ST_DATE_VNA
	 ,NUM_SERIES_PACS2
	 ,num_series_PACS1 
	 ,ST_NUM_SERIES as ST_NUM_SERIES_VNA
	 ,NUM_OBJECT_SERIES_PACS2
	 ,num_object_series_PACS1
	 ,SE_IMAGES_SERIES as SE_IMAGES_SERIES_VNA
	 ,NUM_OBJECTS_STUDY_PACS2
	 ,num_objects_study_PACS1
	 ,ST_IMAGES_STUDY as ST_IMAGES_STUDY_VNA
	 ,Missing_pacs1_pacs2
	 ,NUM_OBJECTS_STUDY_PACS2-ST_IMAGES_STUDY as Missing_pacs2_VNA
	 ,INSTITUTIONAL_DEPARTMENT_NAME_PACS2
	 ,SOURCE_CALLING_TITLE_PACS2 
	 ,STATION_NAME_PACS2 
	 ,STUDY_DESCRIPTION_PACS2 
	 ,MODALITY_PACS2 
	 ,modality_PACS1
	 ,ST_MODALITYINSTUDY as ST_MODALITYINSTUDY_VNA 
	 ,PATIENT_NAME_PACS2 
	 ,PT_DICOMFAMILYNAMECOMPLEX as PT_DICOMFAMILYNAMECOMPLEX_VNA
  FROM #pacs1andpacs2uid s with (nolock)
  join [CARD_PUB].dbo.T_Series se on s.seriesuid_PACS1 = se.SE_DICOM_UID
  join [CARD_PUB].[dbo].[T_Study] st on se.SE_ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT st.ST_FOLDERGUID
		 , count(*) as ST_NUM_SERIES
	  FROM [CARD_PUB].[dbo].[T_Study] st 
		 join [CARD_PUB].[dbo].[T_Series] se on st.ST_FOLDERGUID = se.SE_ST_FOLDERGUID
		 	  group by st.ST_FOLDERGUID) nse on nse.ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT st.ST_FOLDERGUID
		 , count(*) as ST_IMAGES_STUDY
	  FROM [CARD_PUB].[dbo].[T_Study] st 
		 join [CARD_PUB].[dbo].[T_Series] se on st.ST_FOLDERGUID = se.SE_ST_FOLDERGUID
		 join [CARD_PUB].[dbo].[T_Image] im on se.SE_FOLDERGUID = im.IM_SE_FOLDERGUID
	  group by st.ST_FOLDERGUID) nist on nist.ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT se.SE_FOLDERGUID
		 , count(*) as SE_IMAGES_SERIES
	  FROM [CARD_PUB].[dbo].[T_Series] se 
		 join [CARD_PUB].[dbo].[T_Image] im on se.SE_FOLDERGUID = im.IM_SE_FOLDERGUID
	  group by se.SE_FOLDERGUID) nise on nise.SE_FOLDERGUID = se.SE_FOLDERGUID
  join [CARD_PUB].[dbo].[T_Patient] p on p.PT_FOLDERGUID = st.ST_PT_FOLDERGUID

union all

SELECT  
	'CARD_MIG_PUB' as DB 
	 ,PATIENT_ID_PACS2 
	 ,patID_PACS1
	 ,ST_PATIENT_ID as ST_PATIENT_ID_VNA	
	 ,ACCESSION_NUMBER_PACS2
	 ,ST_ACCESSIONNUMBER as ST_ACCESSIONNUMBER_VNA
	 ,STUDY_UID_PACS2
	 ,suid_PACS1 
	 ,st.ST_DICOM_UID as st.ST_DICOM_UID_VNA
	 ,case when STUDY_UID_PACS2 = suid_PACS1 and suid_PACS1 = st.ST_DICOM_UID then 'MATCH' else 'NO MATCH' end as ALL_MATCH
	 ,case when STUDY_UID_PACS2 = suid_PACS1 then 'MATCH' else 'NO MATCH' end as pacs2_pacs1_MATCH
	 ,case when suid_PACS1 = st.ST_DICOM_UID then 'MATCH' else 'NO MATCH' end as pacs1_VNA_MATCH 
	 ,case when STUDY_UID_PACS2 = st.ST_DICOM_UID then 'MATCH' else 'NO MATCH' end as pacs2_VNA_MATCH
	 ,SERIES_UID_PACS2
	 ,seriesuid_PACS1
	 ,se.SE_DICOM_UID as se.SE_DICOM_UID_VNA
	 ,STUDY_DATE_PACS2
	 ,left(studydate_PACS1,8) as studydate_PACS1
	 ,Format(ST_DATE, N'yyyyMMdd') as ST_DATE_VNA
	 ,NUM_SERIES_PACS2
	 ,num_series_PACS1 
	 ,ST_NUM_SERIES as ST_NUM_SERIES_VNA
	 ,NUM_OBJECT_SERIES_PACS2
	 ,num_object_series_PACS1
	 ,SE_IMAGES_SERIES as SE_IMAGES_SERIES_VNA
	 ,NUM_OBJECTS_STUDY_PACS2
	 ,num_objects_study_PACS1
	 ,ST_IMAGES_STUDY as ST_IMAGES_STUDY_VNA
	 ,Missing_pacs1_pacs2
	 ,NUM_OBJECTS_STUDY_PACS2-ST_IMAGES_STUDY as Missing_pacs2_VNA
	 ,INSTITUTIONAL_DEPARTMENT_NAME_PACS2
	 ,SOURCE_CALLING_TITLE_PACS2 
	 ,STATION_NAME_PACS2 
	 ,STUDY_DESCRIPTION_PACS2 
	 ,MODALITY_PACS2 
	 ,modality_PACS1
	 ,ST_MODALITYINSTUDY as ST_MODALITYINSTUDY_VNA
	 ,PATIENT_NAME_PACS2 
	 ,PT_DICOMFAMILYNAMECOMPLEX as PT_DICOMFAMILYNAMECOMPLEX_VNA
  FROM #pacs1andpacs2uid s with (nolock)
  join [CARD_MIG_PUB].dbo.T_Series se on s.seriesuid_PACS1 = se.SE_DICOM_UID
  join [CARD_MIG_PUB].[dbo].[T_Study] st on se.SE_ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT st.ST_FOLDERGUID
		 , count(*) as ST_NUM_SERIES
	  FROM [CARD_MIG_PUB].[dbo].[T_Study] st 
		 join [CARD_MIG_PUB].[dbo].[T_Series] se on st.ST_FOLDERGUID = se.SE_ST_FOLDERGUID
		 	  group by st.ST_FOLDERGUID) nse on nse.ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT st.ST_FOLDERGUID
		 , count(*) as ST_IMAGES_STUDY
	  FROM [CARD_MIG_PUB].[dbo].[T_Study] st 
		 join [CARD_MIG_PUB].[dbo].[T_Series] se on st.ST_FOLDERGUID = se.SE_ST_FOLDERGUID
		 join [CARD_MIG_PUB].[dbo].[T_Image] im on se.SE_FOLDERGUID = im.IM_SE_FOLDERGUID
	  group by st.ST_FOLDERGUID) nist on nist.ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT se.SE_FOLDERGUID
		 , count(*) as SE_IMAGES_SERIES
	  FROM [CARD_MIG_PUB].[dbo].[T_Series] se 
		 join [CARD_MIG_PUB].[dbo].[T_Image] im on se.SE_FOLDERGUID = im.IM_SE_FOLDERGUID
	  group by se.SE_FOLDERGUID) nise on nise.SE_FOLDERGUID = se.SE_FOLDERGUID
  join [CARD_MIG_PUB].[dbo].[T_Patient] p on p.PT_FOLDERGUID = st.ST_PT_FOLDERGUID

union all

SELECT 
	'NONE' as DB 
	 ,PATIENT_ID_PACS2 
	 ,patID_PACS1
	 ,NULL -- ST_PATIENT_ID as ST_PATIENT_ID_VNA	
	 ,ACCESSION_NUMBER_PACS2
	 ,NULL -- ST_ACCESSIONNUMBER as ST_ACCESSIONNUMBER_VNA
	 ,STUDY_UID_PACS2
	 ,suid_PACS1  
	 ,NULL -- st.ST_DICOM_UID as st.ST_DICOM_UID_VNA
	 ,'NA' -- case when STUDY_UID_PACS2 = suid_PACS1 and suid_PACS1 = st.ST_DICOM_UID then 'MATCH' else 'NO MATCH' end as ALL_MATCH
	 ,case when STUDY_UID_PACS2 = suid_PACS1 then 'MATCH' else 'NO MATCH' end as pacs2_pacs1_MATCH
	 ,'NA' -- case when suid_PACS1 = st.ST_DICOM_UID then 'MATCH' else 'NO MATCH' end as pacs1_VNA_MATCH 
	 ,'NA' -- case when STUDY_UID_PACS2 = st.ST_DICOM_UID then 'MATCH' else 'NO MATCH' end as pacs2_VNA_MATCH
	 ,SERIES_UID_PACS2
	 ,seriesuid_PACS1
	 ,NULL -- se.SE_DICOM_UID as se.SE_DICOM_UID_VNA
	 ,STUDY_DATE_PACS2
	 ,left(studydate_PACS1,8) as studydate_PACS1
	 ,NULL -- Format(ST_DATE, N'yyyyMMdd') as ST_DATE_VNA
	 ,NUM_SERIES_PACS2
	 ,num_series_PACS1 
	 ,0 -- ST_NUM_SERIES as ST_NUM_SERIES_VNA
	 ,NUM_OBJECT_SERIES_PACS2
	 ,num_object_series_PACS1
	 ,0 -- SE_IMAGES_SERIES as SE_IMAGES_SERIES_VNA
	 ,NUM_OBJECTS_STUDY_PACS2
	 ,num_objects_study_PACS1
	 ,0 -- ST_IMAGES_STUDY as ST_IMAGES_STUDY_VNA
	 ,Missing_pacs1_pacs2
	 ,NUM_OBJECTS_STUDY_PACS2
	 ,INSTITUTIONAL_DEPARTMENT_NAME_PACS2
	 ,SOURCE_CALLING_TITLE_PACS2 
	 ,STATION_NAME_PACS2 
	 ,STUDY_DESCRIPTION_PACS2 
	 ,MODALITY_PACS2 
	 ,modality_PACS1
	 ,NULL -- ST_MODALITYINSTUDY as ST_MODALITYINSTUDY_VNA
	 ,PATIENT_NAME_PACS2 
	 ,NULL -- PT_DICOMFAMILYNAMECOMPLEX as PT_DICOMFAMILYNAMECOMPLEX_VNA
  FROM #pacs1andpacs2uid s with (nolock)
  left join [CARD_MIG_PUB].[dbo].[T_Series] stm on s.seriesuid_PACS1 = stm.SE_DICOM_UID
  left join [CARD_PUB].[dbo].[T_Series] st on s.seriesuid_PACS1 = st.SE_DICOM_UID
  where st.SE_FOLDERGUID is NULL and stm.SE_FOLDERGUID is NULL

order by ST_DATE desc


IF OBJECT_ID('tempdb..#pacs1andpacs2uid') IS NOT NULL
    DROP TABLE #pacs1andpacs2uid