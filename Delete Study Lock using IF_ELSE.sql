/* Script to delete study edit lock ONLY if the study is not in progress, scheduled to be changed, or locked by the database accessing it itself. Otherwise, print error message 
   Database/table names obscured to avoid sharing any proprietary information.

   Created by: Christopher Wilbar
   Version 1.1 (obfuscated version) - 06-17-2019
*/

declare @idstudy varchar(16)
set @idstudy = (select STUDY_REF from database.dbo.STUDY where ACCESSION_NUMBER = 'ACCESSION_NUMBER')

IF ((select count(studyid) from database1..Inprogress where StudyID = @idstudy)
	+(select count(studyid) from database1..changeset where StudyID = @idstudy)
	+(select count(studyid) from database1..StudyAccessMutex where StudyID = @idstudy))>1 
	AND (select count(studyid) from database1..checkout where StudyID = @idstudy)>=1
print 'ERROR, STUDY IS IN PROGRESS'
ELSE 
delete from database1..checkout where StudyID = @idstudy


