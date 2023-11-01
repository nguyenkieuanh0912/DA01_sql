Ex1
WITH temp_table AS
(
SELECT 
  company_id, 
  title, 
  description, 
  COUNT(job_id) AS job_count
FROM job_listings
GROUP BY company_id, 
  title, 
  description
)
select count(*)
from temp_table
where job_count >=2;

Ex2
