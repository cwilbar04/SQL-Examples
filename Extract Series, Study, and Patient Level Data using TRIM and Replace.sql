/* Script to extract study, series, and patient level data with a line for each Series, with aggregated Study information for each line.
   Study split between two databases, and need to search each independently and combine results.

   database/table names changed to avoid sharing any proprietary information.
   Created by: Christopher Wilbar
   Version 1.1 (database/table name changed version) - 06-18-2019
*/


SELECT
	RTRIM(RTRIM(replace(NAME_L,',','')) + '^' + RTRIM(replace(NAME_F,',',''))) as patient_name
	,RTRIM([IUH_ID]) as MedicalRecordNumber
	,RTRIM(ex.STUDY_UID) as Study_UID
	,RTRIM(se.Series_UID) as Series_UID
	,RTRIM(convert(varchar(8), EXAM_DATE, 112)) as Study_Date
	,RTRIM(st.QR_Modality) as Modality
	,RTRIM(case when Num_Series is NULL then 0 else Num_Series end) as Num_Series
 	,RTRIM(case when Num_Objects_Series is NULL then 0 else Num_Objects_Series end) as Num_Objects_Series 
	,RTRIM(case when Num_Objects_Study is NULL then 0 else Num_Objects_Study end) as Num_Objects_Study
from database1.dbo.EXAM ex
	left join database1.dbo.PATIENT pa on ex.PAT_ID = pa.PAT_ID
	join database2.dbo.Studies st on ex.EXAM_ID = st.EXAM_ID
	left join (select distinct study_id, series_uid from database2.dbo.Images group by Series_UID, Study_ID) se on st.Study_ID = se.Study_ID	
	left join (SELECT Study_ID, count(distinct Series_UID) as Num_Series from database2.dbo.Images group by Study_ID) seno1 on seno1.Study_ID = st.Study_ID
	left join (select Series_UID, COUNT(*) as Num_Objects_Series from database2.dbo.Images group by Series_UID) seimno on seimno.Series_UID = se.Series_UID
	left join (select Study_ID, COUNT(*) as Num_Objects_Study from database2.dbo.Images group by Study_ID) stimno on stimno.Study_ID = st.Study_ID

union all

SELECT
	RTRIM(RTRIM(replace(NAME_L,',','')) + '^' + RTRIM(replace(NAME_F,',',''))) as patient_name
	,RTRIM([IUH_ID]) as MedicalRecordNumber
	,RTRIM(ex.STUDY_UID) as Study_UID
	,RTRIM(se.Series_UID) as Series_UID
	,RTRIM(convert(varchar(8), EXAM_DATE, 112)) as Study_Date
	,RTRIM(st.QR_Modality) as Modality
	,RTRIM(case when Num_Series is NULL then 0 else Num_Series end) as Num_Series
 	,RTRIM(case when Num_Objects_Series is NULL then 0 else Num_Objects_Series end) as Num_Objects_Series 
	,RTRIM(case when Num_Objects_Study is NULL then 0 else Num_Objects_Study end) as Num_Objects_Study
from database1.dbo.EXAM ex
	left join database1.dbo.PATIENT pa on ex.PAT_ID = pa.PAT_ID
	join database2106.dbo.Studies st on ex.EXAM_ID = st.EXAM_ID
	left join (select distinct study_id, series_uid from database2106.dbo.Images group by Series_UID, Study_ID) se on st.Study_ID = se.Study_ID	
	left join (SELECT Study_ID, count(distinct Series_UID) as Num_Series from database2106.dbo.Images group by Study_ID) seno1 on seno1.Study_ID = st.Study_ID
	left join (select Series_UID, COUNT(*) as Num_Objects_Series from database2106.dbo.Images group by Series_UID) seimno on seimno.Series_UID = se.Series_UID
	left join (select Study_ID, COUNT(*) as Num_Objects_Study from database2106.dbo.Images group by Study_ID) stimno on stimno.Study_ID = st.Study_ID
