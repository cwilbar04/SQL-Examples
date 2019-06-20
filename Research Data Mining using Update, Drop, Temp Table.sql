/*
Research Study Data Mining 
Created by: Christopher Wilbar
version 1.1 - 12/11/2017 
version 1.2 - 6-18-2019  - database/table names changed to protect proprietary information
*/


/*The following script is used to identify studies done during a time period for specific MRN's. Data is manipulated
to an acceptable format in Excel and then the Data Import Wizard is used to load to database2.
The query is run in the specific site database where the data is stored. Modifications would be necessary to search 
across the different "Sites". Care is taken to store the original state of the database and to return the 
database to its original state once complete. The Database Search function in the application is leveraged to 
print the EKG's marked with the 'sql' tag in the user defined field by this script. The script is intended to be 
used piece by piece, by running just the code in between comments, one group at a time.

This process completed to avoid using script to load data over network because direct access to SQL Server was not given.*/

/* First, import temporary table from Excel with research data. 
In this case MRN transfomration to twelve digits and admit date to admite date - 1 day performed in Excel 
File was saved as tab-delimeted and import tool used to create table dbo.research in database2 */

IF object_id('tempdb..#researchtable') is not Null
BEGIN
	DROP TABLE #researchtable;
END;

IF object_id('tempdb..#tempuserdefined') is not Null
BEGIN
	DROP TABLE #tempuserdefined;
END;


CREATE TABLE #researchtable (
	mrn nvarchar(max),
	admit datetime,
	discharge datetime
)

INSERT INTO #researchtable (mrn,admit,discharge)
	SELECT [mrn], [24hrbeforeadmit], [discharge]
	FROM database2.dbo.research

SELECT * FROM #researchtable

/* Second store the current value in userdefined column to be stored back after EKG's printed */
CREATE TABLE #tempuserdefined (
	testid nvarchar(max),
	originaluserdefined nvarchar(max)
)

INSERT INTO #tempuserdefined (testid, originaluserdefined)
	SELECT 
		testdemographics.testid,
		testdemographics.userdefined 
	FROM 
			 [testdemographics]
		join [patientdemographics] on [testdemographics].[testid] = [patientdemographics].[testid] 
		join [tests] on [tests].[testID] = [testdemographics].[testid]
		join [#researchtable] on [patientdemographics].[patientID] = [#researchtable].[mrn]
	WHERE 
			[acquisitiondatetime_dt] >= [#researchtable].[admit] 
		and [acquisitiondatetime_dt] <= [#researchtable].[discharge] --all tests performed during the admission
		and [testdemographics].[TestID] > 0  --Negative TestID is a line item for a printed copy of test
		and [testdemographics].[TestType] = 1 --Test Type = = 1 = ECG (not Stress or Holter)
		and [tests].[DBList] = 0 --DBList = 0 => Test is not Discarded (i.e. stored in the accessible database)
		and [testdemographics].FullTestStatusID = 17 -- FullTestStatusID = 17 => Test is in "Confirmed" status (diagnosis signed off by physician)

SELECT * FROM #tempuserdefined

/* Next, update userdefined field for taget tests to allow database search in Muse application */

UPDATE [testdemographics]
	SET 
		[testdemographics].[userdefined] = 'sql'
	FROM 
			 [testdemographics]
		join [patientdemographics] on [testdemographics].[testid] = [patientdemographics].[testid] 
		join [tests] on [tests].[testID] = [testdemographics].[testid]
		join [#researchtable] on [patientdemographics].[patientID] = [#researchtable].[mrn]
	WHERE 
			[acquisitiondatetime_dt] >= [#researchtable].[admit] 
		and [acquisitiondatetime_dt] <= [#researchtable].[discharge] --all tests performed during the admission
		and [testdemographics].[TestID] > 0  --Negative TestID is a line item for a printed copy of test
		and [testdemographics].[TestType] = 1 --Test Type = 1 => ECG study (not Stress or Holter)
		and [tests].[DBList] = 0 --DBList = 0 => Test is not Discarded (i.e. stored in the accessible database)
		and [testdemographics].FullTestStatusID = 17 -- FullTestStatusID = 17 => Test is in "Confirmed" status (diagnosis signed off by physician)

SELECT * FROM [testdemographics] WHERE [testdemographics].[userdefined] = 'sql' and TestID>0

/*Spot check that appropriate data was found. Then go to the MUSE application and run database search for all tests with user defined 'sql' 
Print these tests to "Research" device in MUSE then come back here*/

/*Once results have printed, restore original userdefined value and finish by dropping both temp tables*/

UPDATE [testdemographics]
	SET 
		[testdemographics].[userdefined] = #tempuserdefined.originaluserdefined
	FROM 
			 [testdemographics]
		join [patientdemographics] on [testdemographics].[testid] = [patientdemographics].[testid] 
		join [tests] on [tests].[testID] = [testdemographics].[testid]
		join [#researchtable] on [patientdemographics].[patientID] = [#researchtable].[mrn]
		join [#tempuserdefined] on [testdemographics].[testid] = [#tempuserdefined].[testid]
	WHERE 
			[acquisitiondatetime_dt] >= [#researchtable].[admit] 
		and [acquisitiondatetime_dt] <= [#researchtable].[discharge] --all tests performed during the admission
		and [testdemographics].[TestID] > 0  --Negative TestID is a line item for a printed copy of test
		and [testdemographics].[TestType] = 1 --Test Type = 1 => ECG study (not Stress or Holter)
		and [tests].[DBList] = 0 --DBList = 0 => Test is not Discarded (i.e. stored in the accessible database)
		and [testdemographics].FullTestStatusID = 17 -- FullTestStatusID = 17 => Test is in "Confirmed" status (diagnosis signed off by physician)

SELECT * FROM [testdemographics] WHERE [testdemographics].[userdefined] = 'sql'and TestID>0

IF object_id('tempdb..#researchtable') is not Null
BEGIN
	DROP TABLE #researchtable;
END;

IF object_id('tempdb..#tempuserdefined') is not Null
BEGIN
	DROP TABLE #tempuserdefined;
END;


/* Finally, delete the table created in the database2 Database manually*/