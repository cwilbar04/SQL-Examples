/****** Script for Extracting Relevant Data from the Database ******/
/****** Created by: Christopher Wilbar
		Version 1.1 Created 1/25/2019
		Version 1.2 Created 6/19/2019 - removed proprietary information						  ******/
		
/* Script is broken up in to sections to Extract Relevant Data as Indicated.
	Site Information May need to be updated if working with Multiple Sites.
	Default is to only site database1 database where Site Information is needed
	
	Different Sections
		1. User Info 
*/
		
/*Drop Temp Tables just in case */
IF OBJECT_ID('tempdb..#lastlogin') IS NOT NULL
    DROP TABLE #lastlogin
;

/* 1. User Info */
/*
create table #lastlogin(
	PersonID int primary key 
	,LastLogin varchar(10)
	)
;

insert into #lastlogin
	SELECT 
	a.PersonID
	 ,convert(varchar(10),MAX(dateadd(hh,-6,StartDateTime_UTC)),112)as LastLogin
	FROM [System].[dbo].[cfgPersons] a with (nolock)
	  LEFT JOIN [System].[dbo].[logProcess] b on a.PersonID = b.PersonID
	group by a.PersonID
--	having MAX(dateadd(hh,-6,StartDateTime_UTC)) > '2016-12-31'  --remove dashes to restrict users to only those logged in since certain time
	order by LastLogin desc
;

select 
	UserID
	,a.WindowsUserName
	,FirstName + ' ' + LastName as Name
	,a.RoleID
	,RoleName
	,d.PublishedProfileID
	,ProfileName
	,LastLogin
	,UserActive
	,UserEnabled
 from #lastlogin l
	JOIN System.dbo.cfgPersons a on a.PersonID = l.PersonID
	LEFT JOIN [System].dbo.cfgRoles c on a.RoleID = c.RoleID
	LEFT JOIN [System].dbo.cfgPersonsProfiles d on a.PersonID = d.PersonID
	LEFT JOIN [System].dbo.cfgPublishedProfiles e on d.PublishedProfileID = e.PublishedProfileID 
 order by LastLogin desc
; 
*/

/* 2. System Info */
/*
select
	*
from System.dbo.cfgSystem
*/

/* 3. Site Info */

/*
select
	*
from System.dbo.cfgSites
*/

/* 4. Location and HIS Location Info */
/* Need to change Site number in joins to get multiple sites */
/*
SELECT 
	HISLocation
	,TestType
	,b.MUSELocationID
	,c.FullName
	,COUNT(a.TestID) as Number_of_Studies
	,MAX(a.OrderTime) as Most_Recent_Order_Time
  FROM [database1].[dbo].[tstHISObject] a
	left join database1.dbo.cfgHISLocations b on a.HISLocation = b.HISLocationText
	left join database1.dbo.cfgLocations c on b.MUSELocationID = c.LocationID
	left join database1.dbo.tstTestDemographics d on a.TestID = d.TestID
  where a.TestID > 0 and OrderTime <= getdate()
  group by HISLocation, TestType,MUSELocationID,FullName
  order by HISLocation
 */
  
/*  5. ECG Cart Info */
/* Need to change Site number in joins to get multiple sites */
/*
SELECT
	CartNumber
	,[CartID]
	,[AcquisitionDevice]
	,[AcquisitionSoftwareVersion]
	,AnalysisSoftwareVersion
	,[Location]
	,FullName
	,COUNT(a.TestID) as Number_of_Studies
	,left(convert(varchar(10),AcquisitionDateTime_DT,112),4) as Year
	FROM [database1].[dbo].[tstTestDemographics] a with (nolock) 
		left join [database1].[dbo].[tstPharmaTestInformation] b with (nolock) on a.TestID = b.TestID
		left join database1.dbo.cfgLocations c with (nolock) on a.Location = c.LocationID
	where a.TestID > 0 
	and TestStatus != 128 
	and TestType = 1
	--and left(convert(varchar(10),AcquisitionDateTime_DT,112),4) = '2019'
	group by left(convert(varchar(10),AcquisitionDateTime_DT,112),4),Location, FullName, CartID, CartNumber, AcquisitionDevice,AcquisitionSoftwareVersion,AnalysisSoftwareVersion
	order by CartID
	
*/  

/* Number of Studies by Test Type */
/*
SELECT
	left(convert(varchar(10),AcquisitionDateTime_DT,112),4) as Year
	,a.TestType 
	,FullName
	,COUNT(a.TestID) as Number_of_Studies
FROM database1.dbo.tstTestDemographics a
	JOIN database1.dbo.cfgTestTypeQualifiers b on a.TestType = b.TestType
WHERE TestID > 0 
and b.TestTypeQualifier = 0 
and TestStatus != 128
Group by left(convert(varchar(10),AcquisitionDateTime_DT,112),4), a.TestType, FullName 
Order by Year desc
*/	


/* All studies in specific Locations and Test Types */
/*
SELECT
	case when [Location] = 1 then 'McHenry' else case when [Location] = 201 then 'Woodstock' else 'Huntley' end end as Hospital
	,[Location] as Location_ID
	,FullName as Location_Name
	,AcquisitionDateTime_DT
	,PatientID
	,PatientFullName_Last
	,PatientFullName_First
	,DateOfBirth_D
	,TestStatus
	,FullTestStatusID
	,EnumString
	,DBList
	--,COUNT(a.TestID) as Number_of_Studies
	--,left(convert(varchar(10),AcquisitionDateTime_DT,112),4) as 'Year'
	FROM [database1].[dbo].[tstTestDemographics] a with (nolock)
		left join [database1].dbo.tstPatientDemographics d with (nolock) on a.TestID = d.TestID 
		left join [database1].dbo.tstTests e on a.TestID = e.TestID
		left join [database1].[dbo].[tstPharmaTestInformation] b with (nolock) on a.TestID = b.TestID
		left join database1.dbo.cfgLocations c with (nolock) on a.Location = c.LocationID
		left join [database1].[dbo].[cfgDataDictEnums] f on f.StringIndex = a.FullTestStatusID and FieldID = 987
	where a.TestID > 0 
	and TestStatus != 128 
	and a.TestType = 1
	and AcquisitionDateTime_DT >= '20180801'
	and Location in ('1','201','301')
	--and left(convert(varchar(10),AcquisitionDateTime_DT,112),4) = '2019'
	--group by 
	--left(convert(varchar(10),AcquisitionDateTime_DT,112),4)
	--,Location
	--,FullName
	order by AcquisitionDateTime_DT
*/
	
	
/*Drop all temp tables */
  IF OBJECT_ID('tempdb..#lastlogin') IS NOT NULL
    DROP TABLE #lastlogin
;