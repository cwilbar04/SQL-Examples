/****** Script for CASE-SENSITIVE comparison of how users have logged in to system and how their user is built in the system. Collation forces Case-Sensitive Matches

		Created By: Christopher Wilbar
		Version 1.1 06-20-2019 - database/table names changed
 ******/



SELECT
	Department
	  ,[Name]
      ,a.[UserName] COLLATE Latin1_General_CS_AS as login_name
	  ,c.username as sysadmin_name
      ,max([LicenseAcquired]) as lastlogin
	  ,case when a.[UserName] COLLATE Latin1_General_CS_AS = c.username COLLATE Latin1_General_CS_AS then 'match' else 'NEEDS ATTENTION' end as 'Status'
  FROM [database1].[dbo].[LicenseHistory] a with (nolock) 
  join  [database2].[dbo].[DEPARTMENT] b with (nolock) on a.Department = b.DEPARTMENT_NAME
  join  [database1].[dbo].[Users] c with (nolock) on b.DEPARTMENT_REF = c.DepartmentID
  join  [database1].[dbo].[UserRoles] d with (nolock) on c.ID = d.UserID
  join	[database1].[dbo].[Role] e with (nolock) on d.RoleID = e.ID
  where
	a.UserName = c.UserName 
	--and [Name] not in ('Referring Physicians', 'Web_Users', 'Diagnostic_Cardio_Support', 'Sonographers', 'Front Desk', 'West_Tech', 
	--					'Referring_Physicians','Nurse','TECH_SUPER_USER','Technologists','Clinical_Admins','Super_User','Coding_Billing'
	--					,'Exercise_Physiologist','Security_Admins', 'West_MD', 'Cadence_Referring_Physicians')
	and DEPARTMENT_REF not in (1019, 1021, 1022, 1024, 1029, 1030, 1031)
    group by a.UserName COLLATE Latin1_General_CS_AS, c.UserName, Department, [Name]
	order by a.UserName COLLATE Latin1_General_CS_AS

