/*****Script used to create summary statistics on the type of objects on Cache in PACS system.
	All Queries commented out by default. Add -- on lines with /* and */ before and after query to run a specific query.
	
		Queries are separated out to get statistics on:
			1. Percentage of Unverified Studies on Cache
			2. Percentage of Unverified Objects on Cache
			3. Percentage of Cache used by Unverified Objects on Cache
			4. Number of Objects and Percentage of Cache by Modality Type for Top 8 Modalities
			5. Number of Objects and Percentage of Cache by Department
			6. Number of Objects and Percentage of Cache by SOP Class UID for Top 8 
			7. Number of Objects and Percentage of Cache by Manufacture and Model for Top 8 
			8. Number of Objects and Percentage of Cache by Station Name for Top 20
			9. Number of Objects and Percentage of Cache by Date
			10. Percentage of Studies by whether they have been archived

  
  Created by: Christopher Wilbar 
  Version 1.0 10-30-2018
  Version 1.1 06-17-2019 - table names obscured to protect propietary information
*******/

/***First we declare a temp variable for the total cache size in GB that will be used to calcaulate percentages of cache throughout ***/
  declare @totalcachesizeGB float ;
  declare @totalcachestudies float ;
  declare @totalcacheobjects float ;
  
  set @totalcachesizeGB = 
	(select 
			sum(object_length/1073741824.)   -- date stored as bytes -> divide by this number to get data in GB (1 GB = 1073741824 bytes)
		from [database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
		where 
			VOLUME_REF = '4416' --Volume_Ref = 4416 -> In folder on Server i.e. Syngo Cache on H: drive
	) 
  ;



  set @totalcachestudies =
	(select
			count(*)
		from 
			[database].[dbo].[STUDY] with (nolock) 
		where 
			[IS_CACHED] = 'T' 
	)
  ;

  set @totalcacheobjects =
	(select
			count(*)
		from [database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
		where 
			VOLUME_REF = '4416'
	)
  ;

/*** Uncomment to dispaly total sizes ***/
 /* 
  select 
   @totalcachesizeGB as Total_Cache_Size_GB
   ,@totalcachestudies as Total_Cache_Studies
   ,@totalcacheobjects as Total_Cache_Objects
 */


/*** If needed, uncomment this section for an example row of all data available for each record used in the Join statements (i.e. Object, Series, and Study level data for each object) ***/
 
 /*
  select 
		top 1 *
	from 
		[database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
	where 
		VOLUME_REF = '4416'
 */


/****  1. Percentage of Unverified Studies on Cache  ****/

 /*
  select 
		count(*) as Number_of_Unverified_Studies
		,count(*)*100/@totalcachestudies as Percent_of_Cache_is_Unverified_Studies
	from 
		database.dbo.STUDY with (nolock)
	where
		IS_CACHED = 'T'  -- Study is On Cache
		and DATE_TIME_VERIFIED < 0  --DATE_TIME_VERIFED < 0 -> Study failed to HIS verify 
 */

/****  2. Percentage of Unverified Objects on Cache  ****/

 /*
  select 
		sum(object_length/1073741824.) as Size_of_Unverified_GB
		,sum(object_length/1073741824.)*100/@totalcachesizeGB as Percentage_of_Cache_Used_By_Unverified
	from 
		[database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
	where 
		VOLUME_REF = '4416' -- In folder on Server i.e. in Syngo Cache on G: drive
		and DATE_TIME_VERIFIED < 0 -- Study failed to HIS verify 
 */

/****  3. Percentage of Cache used by Unverified Objects on Cache  ****/

 /*
   select
		count(*) as Number_of_Unverified_Objects
		,count(*)*100/@totalcacheobjects as Percent_of_Cache_is_Unverified_Objects
	from 
		[database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
	where 
		VOLUME_REF = '4416' -- In folder on Server i.e. Syngo Cache on G: drive
		and DATE_TIME_VERIFIED < 0 -- Study failed to HIS verify 
 */

/**** 4. Number of Objects and Percentage of Cache by Modality Type for Top 8 Modalities  ****/
 
 /* 
  select 
	top 8 --remove this if you want all modalities
		c.Modality
		,count(c.MODALITY) as Number_of_Objects_On_Cache
		,sum(object_length/1073741824.) as Space_Used_GB
		,sum(object_length/1073741824.)*100/@totalcachesizeGB as Percentage_of_Cache
	from 
		[database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
	where 
		VOLUME_REF = '4416' --Volume_Ref = 1000 -> In folder on Server i.e. Syngo Cache on G: drive
		and INSTITUTIONAL_DEPARTMENT_NAME not in ('IMPORT','LA_VOLUME_Testing','TEST') -- Study in Production Department, i.e. not external study or testing study
	group by 
		c.MODALITY
	order by 
		Percentage_of_Cache desc
  */

/**** 5. Number of Objects and Percentage of Cache by Department  ****/
 
 /* 
  select 
		INSTITUTIONAL_DEPARTMENT_NAME
		,count(INSTITUTIONAL_DEPARTMENT_NAME) as Number_of_Objects_On_Cache
		,sum(object_length/1073741824.) as Space_Used_GB
		,sum(object_length/1073741824.)*100/@totalcachesizeGB as Percentage_of_Cache
	from 
		[database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
	where 
		VOLUME_REF = '4416' --Volume_Ref = 1000 -> In folder on Server i.e. Syngo Cache on G: drive
	group by 
		INSTITUTIONAL_DEPARTMENT_NAME
	order by 
		Percentage_of_Cache desc
  */

/**** 6. Number of Objects and Percentage of Cache by SOP Class UID for Top 8 ****/

 /*
  select 
	top 8 --remove this if you want all 
		UID_TITLE
		,SOP_CLASS_UID
		,count(SOP_CLASS_UID) as Number_of_Objects_On_Cache
		,sum(object_length/1073741824.) as Space_Used_GB
		,sum(object_length/1073741824.)*100/@totalcachesizeGB as Percentage_of_Cache
	from 
		[database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
			left join [database].[dbo].[DICOM_UID] e on b.SOP_CLASS_UID =e.UID_VALUE
	where 
		VOLUME_REF = '4416' --Volume_Ref = 1000 -> In folder on Server i.e. Syngo Cache on G: drive
		and INSTITUTIONAL_DEPARTMENT_NAME not in ('IMPORT','LA_VOLUME_Testing','TEST') -- Study in Production Department, i.e. not external study or testing study
	group by 
		SOP_CLASS_UID, UID_TITLE
	order by 
		Percentage_of_Cache desc
 */

/**** 7. Number of Objects and Percentage of Cache by Manufacture and Model for Top 8 ****/

 /*
  select 
	--top 8 --remove this if you want all modalities
		MANUFACTURER + ' ' + MANUFACTURER_MODEL_NAME as Manufacturer_and_Model
		,c.Modality
		,count(MANUFACTURER) as Number_of_Objects_On_Cache
		,sum(object_length/1073741824.) as Space_Used_GB
		,sum(object_length/1073741824.)*100/@totalcachesizeGB as Percentage_of_Cache
	from 
		[database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
	where 
		VOLUME_REF = '4416' --Volume_Ref = 1000 -> In folder on Server i.e. Syngo Cache on G: drive
		and INSTITUTIONAL_DEPARTMENT_NAME not in ('IMPORT','LA_VOLUME_Testing','TEST') -- Study in Production Department, i.e. not external study or testing study
	group by 
		MANUFACTURER,MANUFACTURER_MODEL_NAME,c.MODALITY
	order by 
		Percentage_of_Cache desc
 */   

 /**** 8. Number of Objects and Percentage of Cache by Station Name for Top 20 ****/

 /*
  select 
	top 20 --remove this if you want all 
		d.STATION_NAME
		,count(d.STATION_NAME) as Number_of_Objects_On_Cache
		,sum(object_length/1073741824.) as Space_Used_GB
		,sum(object_length/1073741824.)*100/@totalcachesizeGB as Percentage_of_Cache
	from 
		[database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
	where 
		VOLUME_REF = '4416' --Volume_Ref = 1000 -> In folder on Server i.e. Syngo Cache on G: drive
		and INSTITUTIONAL_DEPARTMENT_NAME not in ('IMPORT','LA_VOLUME_Testing','TEST') -- Study in Production Department, i.e. not external study or testing study
	group by 
		d.STATION_NAME
	order by 
		Percentage_of_Cache desc
 */

  /**** 9. Number of Objects and Percentage of Cache by Date ****/

 --/*
  select 
		case when left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) > '2017-12' then left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) else left(STUDY_DATE,4) end as 'Date'
		,volume_ref
		,count(left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2))  as Number_of_Objects_On_Cache
		,sum(object_length/1073741824.) as Space_Used_GB
		,sum(object_length/1073741824.)*100/@totalcachesizeGB as Percentage_of_Cache
	from 
		[database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
	where 
	1=1
		--VOLUME_REF = '4416' --Volume_Ref = 1000 -> In folder on Server i.e. Syngo Cache on G: drive
	--	and INSTITUTIONAL_DEPARTMENT_NAME not in ('IMPORT','LA_VOLUME_Testing','TEST') -- Study in Production Department, i.e. not external study or testing study
	group by 
		case when left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) > '2017-12' then left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) else left(STUDY_DATE,4) end, VOLUME_REF
	order by 
		case when left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) > '2017-12' then left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) else left(STUDY_DATE,4) end desc
 --*/

   select 
		case when left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) > '2017-12' then left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) else left(STUDY_DATE,4) end as 'Date'
		,volume_ref
		,count(left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2))  as Number_of_Objects_On_Cache
		,sum(object_length/1073741824.) as Space_Used_GB
		,sum(object_length/1073741824.)*100/@totalcachesizeGB as Percentage_of_Cache
	from 
		[database].[dbo].[OSR_LOCATION] a with (nolock) 
			left join [database].[dbo].[OBJECT] b on a.OBJECT_REF = b.OBJECT_REF
			left join [database].[dbo].[SERIES] c on b.SERIES_REF = c.SERIES_REF
			left join [database].[dbo].[STUDY] d on c.STUDY_REF = d.STUDY_REF
	where 
	1=1
		--VOLUME_REF = '4416' --Volume_Ref = 1000 -> In folder on Server i.e. Syngo Cache on G: drive
	--	and INSTITUTIONAL_DEPARTMENT_NAME not in ('IMPORT','LA_VOLUME_Testing','TEST') -- Study in Production Department, i.e. not external study or testing study
	group by 
		case when left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) > '2017-12' then left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) else left(STUDY_DATE,4) end, VOLUME_REF
	order by 
		case when left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) > '2017-12' then left(STUDY_DATE,4) + '-' + right(left(STUDY_DATE,6),2) else left(STUDY_DATE,4) end desc