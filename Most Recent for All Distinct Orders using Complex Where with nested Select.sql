/* Script for extracting all unique Order Types in MUSE and the most recent example of each.
  Complex select statments needed because ECG and Stress are Confirmed, while all else isn't. 
  Use the most recent confirm time for those that are confirmed, else the most recent order time.

  Database/table names changed to avoid sharing any proprietary information.
   Created by: Christopher Wilbar
   Version 1.1 (database/table name changed version) - 06-17-2019
*/


SELECT 
	ExtraVisitData1
	,OrderTime
	,ConfirmDateTime_DT
	,HISTestType
	,HISTestTypeText
	,OrderNumber
	,VisitNumber
	,TestType
FROM 
	[SITE0001].[dbo].[HISObject] a with (nolock) 
	join [SITE0001].[dbo].[TestDemographics] b with (nolock) on a.TestID = b.TestID 
WHERE 
	a.TestID in 
		(SELECT
			max(a.TestID)
		FROM 
			[SITE0001].[dbo].[HISObject] a with (nolock) 
			join [SITE0001].[dbo].[TestDemographics] b with (nolock) on a.TestID = b.TestID 
		WHERE
			a.TestID > 0
			and HISTestTypeText in 
				(SELECT distinct 
					HISTestTypeText 
				 FROM 
					[SITE0001].[dbo].[HISObject] 
				 WHERE 
					OrderTime > '2018-08-01' 
					and a.TestID>0 
					and TestType != 4
				)
			and ConfirmDateTime_DT is not NULL
			and OrderTime > '2018-08-01'
		GROUP BY ExtraVisitData1, HISTestTypeText
		)
	OR a.TestID in
		(SELECT 
			max(a.TestID)
		 FROM 
			[SITE0001].[dbo].[HISObject] a with (nolock) 
			join [SITE0001].[dbo].[TestDemographics] b with (nolock) on a.TestID = b.TestID 
		 WHERE
			a.TestID > 0
			and HISTestTypeText in 
				(SELECT distinct 
					HISTestTypeText 
				 FROM 
					[SITE0001].[dbo].[HISObject] 
				 WHERE 
					OrderTime > '2018-08-01' 
					and a.TestID > 0 
					and TestType = 4
				)
			and OrderNumber is not NULL
			and TestStatus != 128
			and OrderTime > '2018-08-01'
		GROUP BY ExtraVisitData1, HISTestTypeText
		)

UNION ALL

SELECT 
	ExtraVisitData1
	,OrderTime
	,ConfirmDateTime_DT
	,HISTestType
	,HISTestTypeText
	,OrderNumber
	,VisitNumber
	,TestType
FROM 
	[SITE0002].[dbo].[HISObject] a with (nolock) 
	JOIN [SITE0002].[dbo].[TestDemographics] b with (nolock) on a.TestID = b.TestID 
WHERE 
	a.TestID in 
		(SELECT 
			max(a.TestID)
		 FROM [SITE0002].[dbo].[HISObject] a with (nolock) 
			JOIN [SITE0002].[dbo].[TestDemographics] b with (nolock) on a.TestID = b.TestID 
		 WHERE
			a.TestID > 0
			and HISTestTypeText in 
				(SELECT distinct 
					HISTestTypeText 
				 FROM 
					[SITE0002].[dbo].[HISObject] 
				 WHERE 
					OrderTime > '2018-08-01' and a.TestID > 0
					and TestType != 4
				)
			and ConfirmDateTime_DT is not NULL
			and OrderTime > '2018-08-01'
		 GROUP BY ExtraVisitData1, HISTestTypeText
		 )
    OR a.TestID in
		(SELECT 
			max(a.TestID)
		 FROM 
			[SITE0002].[dbo].[HISObject] a with (nolock) 
			join [SITE0002].[dbo].[TestDemographics] b with (nolock) on a.TestID = b.TestID 
		 WHERE
			a.TestID > 0
			and TestType = 4
			and HISTestTypeText in 
				(SELECT distinct 
					HISTestTypeText 
				 FROM 
					[SITE0002].[dbo].[HISObject] 
				 WHERE 
					OrderTime > '2018-08-01'
				)
			and OrderNumber is not NULL
			and TestStatus != 128
			and OrderTime > '2018-08-01'
		 GROUP BY ExtraVisitData1, HISTestTypeText
		)
ORDER BY HISTestTypeText asc







