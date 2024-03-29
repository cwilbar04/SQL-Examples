 /* Script to get statistics regarding missing field in Database and where a certain field doesn't equal the other field.

   Database/table names changed to avoid sharing any proprietary information.
   Created by: Christopher Wilbar
   Version 1.1 (database/table name changed version) - 06-17-2019
*/

  declare @begindate varchar(10) = '20190101'
  
  SELECT 
  DATEPART(WEEK,PlanDate) as Week_Number
  ,min(PlanDate) as Week_Of
  ,sum(case when ReferringPhysician = ' ' then 1 else 0 end) as No_Referring_Physician
  ,sum(case when ReferringPhysician != ' ' then 1 else 0 end) as Reffering_Physician_Populated
  ,sum(case when RequestingPhysician = ' ' then 1 else 0 end) as No_Requesting_Physician
  ,sum(case when RequestingPhysician != ' ' then 1 else 0 end) as Requesting_Physician_Populated
  ,sum(case when ReferringPhysician != ' ' then case when ReferringPhysician = RequestingPhysician then 1 else 0 end end) as Referring_Requesting_Match
  ,count(*) as Total_Orders
  ,sum(case when ReferringPhysician = ' ' then 1 else 0 end)*100/count(*) as Percentage_No_Referring
  ,100-(sum(case when ReferringPhysician != ' ' then case when ReferringPhysician = RequestingPhysician then 1 else 0 end end)*100/sum(case when ReferringPhysician != ' ' then 1 else 0 end)) as Percentage_Requesting_Not_Equal_Referring
  FROM [DATABASE1].[dbo].[Exams]
  WHERE PlanDate >= @begindate
  GROUP BY DATEPART(WEEK,PlanDate)