/* Script for finding detailed information at the Series Level for study stored in VNA , possibly split or copied between two separate databases. 
   Able to search by Study UID, Accession Number, or Series UID.
   Database/table names obscured to avoid sharing any proprietary information.
 
   Created by: Christopher Wilbar
   Version 1.1 (obfuscated version) - 06-17-2019
*/
     

IF OBJECT_ID('tempdb..#studyfolder') IS NOT NULL
    DROP TABLE #studyfolder

declare @identifier varchar(256)

-- Indentifier Options: Study UID, Accession Number, or Series UID
set @identifier = 'identifier'


create table #studyfolder
	(stfolderguid varchar(256)
	 )

INSERT INTO #studyfolder
		SELECT
		distinct
			ST_FOLDERGUID
		FROM 
			[CARD].[dbo].[T_Study] st with (nolock)
			join [CARD].[dbo].[T_Series] se with (nolock) on se.SE_ST_FOLDERGUID = st.ST_FOLDERGUID
		WHERE
			st.ST_DICOM_UID = @identifier 
			OR se.SE_DICOM_UID = @identifier
			OR ST_ACCESSIONNUMBER = @identifier
	union all
		SELECT
		distinct
			ST_FOLDERGUID
		FROM 
			[CARD_MIG].[dbo].[T_Study] st with (nolock)
			join [CARD_MIG].[dbo].[T_Series] se with (nolock) on se.SE_ST_FOLDERGUID = st.ST_FOLDERGUID
		WHERE
			st.ST_DICOM_UID = @identifier 
			OR se.SE_DICOM_UID = @identifier
			OR ST_ACCESSIONNUMBER = @identifier
;
		

SELECT  
	'CARD' as DB 
	 ,ST_PATIENT_ID	
	 ,ST_ACCESSIONNUMBER
	 ,st.ST_DICOM_UID
	 ,se.SE_DICOM_UID
	 ,Format(ST_DATE, N'yyyyMMdd') as ST_DATE
	 ,ST_NUM_SERIES
	 ,SE_IMAGES_SERIES
	 ,ST_IMAGES_STUDY
	 ,ST_MODALITYINSTUDY 
	 ,PT_DICOMFAMILYNAMECOMPLEX
  FROM [#studyfolder] f 
  join [CARD].[dbo].[T_Study] st on f.stfolderguid = st.ST_FOLDERGUID 
  join [CARD].[dbo].[T_Series] se on se.SE_ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT st.ST_FOLDERGUID
		 , count(*) as ST_NUM_SERIES
	  FROM [CARD].[dbo].[T_Study] st 
		 join [CARD].[dbo].[T_Series] se on st.ST_FOLDERGUID = se.SE_ST_FOLDERGUID
		 	  group by st.ST_FOLDERGUID) nse on nse.ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT st.ST_FOLDERGUID
		 , count(*) as ST_IMAGES_STUDY
	  FROM [CARD].[dbo].[T_Study] st 
		 join [CARD].[dbo].[T_Series] se on st.ST_FOLDERGUID = se.SE_ST_FOLDERGUID
		 join [CARD].[dbo].[T_Image] im on se.SE_FOLDERGUID = im.IM_SE_FOLDERGUID
	  group by st.ST_FOLDERGUID) nist on nist.ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT se.SE_FOLDERGUID
		 , count(*) as SE_IMAGES_SERIES
	  FROM [CARD].[dbo].[T_Series] se 
		 join [CARD].[dbo].[T_Image] im on se.SE_FOLDERGUID = im.IM_SE_FOLDERGUID
	  group by se.SE_FOLDERGUID) nise on nise.SE_FOLDERGUID = se.SE_FOLDERGUID
  join [CARD].[dbo].[T_Patient] p on p.PT_FOLDERGUID = st.ST_PT_FOLDERGUID


union all

SELECT  
	'CARD_MIG' as DB 
	 ,ST_PATIENT_ID	
	 ,ST_ACCESSIONNUMBER
	 ,st.ST_DICOM_UID
	 ,se.SE_DICOM_UID
	 ,Format(ST_DATE, N'yyyyMMdd') as ST_DATE
	 ,ST_NUM_SERIES
	 ,SE_IMAGES_SERIES
	 ,ST_IMAGES_STUDY
	 ,ST_MODALITYINSTUDY 
	 ,PT_DICOMFAMILYNAMECOMPLEX
  FROM #studyfolder f
  join [CARD_MIG].dbo.T_Study st on f.stfolderguid = st.ST_FOLDERGUID
  join [CARD_MIG].[dbo].[T_Series] se on se.SE_ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT st.ST_FOLDERGUID
		 , count(*) as ST_NUM_SERIES
	  FROM [CARD_MIG].[dbo].[T_Study] st 
		 join [CARD_MIG].[dbo].[T_Series] se on st.ST_FOLDERGUID = se.SE_ST_FOLDERGUID
		 	  group by st.ST_FOLDERGUID) nse on nse.ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT st.ST_FOLDERGUID
		 , count(*) as ST_IMAGES_STUDY
	  FROM [CARD_MIG].[dbo].[T_Study] st 
		 join [CARD_MIG].[dbo].[T_Series] se on st.ST_FOLDERGUID = se.SE_ST_FOLDERGUID
		 join [CARD_MIG].[dbo].[T_Image] im on se.SE_FOLDERGUID = im.IM_SE_FOLDERGUID
	  group by st.ST_FOLDERGUID) nist on nist.ST_FOLDERGUID = st.ST_FOLDERGUID
  join (SELECT se.SE_FOLDERGUID
		 , count(*) as SE_IMAGES_SERIES
	  FROM [CARD_MIG].[dbo].[T_Series] se 
		 join [CARD_MIG].[dbo].[T_Image] im on se.SE_FOLDERGUID = im.IM_SE_FOLDERGUID
	  group by se.SE_FOLDERGUID) nise on nise.SE_FOLDERGUID = se.SE_FOLDERGUID
  join [CARD_MIG].[dbo].[T_Patient] p on p.PT_FOLDERGUID = st.ST_PT_FOLDERGUID

order by ST_DATE desc



IF OBJECT_ID('tempdb..#studyfolder') IS NOT NULL
    DROP TABLE #studyfolder