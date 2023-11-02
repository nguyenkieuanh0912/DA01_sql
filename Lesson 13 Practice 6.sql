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
with temp_table as
(select category, product, sum(spend) as total_spend,
RANK () OVER(PARTITION BY category ORDER BY sum(spend) DESC) as rank_number
FROM product_spend
WHERE EXTRACT(year from transaction_date)='2022' 
GROUP BY category, product)
select category, product, total_spend
from temp_table
where rank_number <=2
order by category, total_spend desc 
;

EX3
select count(policy_holder_id ) as member_count
from (select policy_holder_id 
from callers
group by policy_holder_id
having count(case_id) >=3) as t1
;

EX4
select page_id 
from pages 
where page_id not in (select page_id 
from page_likes
group by page_id
having count(user_id) >0)

EX5
with active_user_in_July AS
(SELECT user_id, event_id, event_date, event_type
FROM user_actions
where extract (month from event_date) = 7
and extract(year from event_date)=2022
and event_type in ( 'sign-in', 'like', 'comment')
)
select 
7 as month,count(distinct user_id) as monthly_active_users
from active_user_in_July 
where user_id in (select user_id
from user_actions
where extract (month from event_date) = 6
and extract(year from event_date)=2022
and event_type in ( 'sign-in', 'like', 'comment'))
;

EX6
WITH cte as
(select id ,country, state , amount, trans_date , TO_CHAR(trans_date, 'yyyy-mm') as month
from Transactions),
cte1 as
(select 
month, country, count(trans_date) as trans_count, 
sum(amount) as trans_total_amount
from cte
group by month, country
),
cte2 as 
(select 
month, country, count(trans_date) as approved_count, 
sum(amount) as approved_total_amount
from cte
where state='approved '
group by month, country
)
select a.month,a.country, a.trans_count, b.approved_count,
a.trans_total_amount, b.approved_total_amount
from cte1 as a
join cte2 as b on a.month=b.month and a.country=b.country
;

EX7
select product_id, year as first_year, quantity, price from Sales as b
where year = (select min(year) as first_year
from Sales as a
where a.product_id=b.product_id
group by product_id);
  
EX8
select customer_id
from Customer
group by customer_id
having count(distinct product_key) = 
(select count(distinct product_key)
from Product);
  
EX9
select employee_id
from Employees
where salary<30000
and manager_id is not null 
and manager_id not in (select employee_id
from Employees)
order by employee_id;

EX10
select employee_id,
case 
when 
employee_id in (select employee_id
from Employee 
group by employee_id
having count(department_id)>=2) and primary_flag ='Y' then department_id
when employee_id in (select employee_id
from Employee 
group by employee_id
having count(department_id)=1) and primary_flag='N' then department_id
end as department_id
from Employee
where (case 
when 
employee_id in (select employee_id
from Employee 
group by employee_id
having count(department_id)>=2) and primary_flag ='Y' then department_id
when employee_id in (select employee_id
from Employee 
group by employee_id
having count(department_id)=1) and primary_flag='N' then department_id
end) is not null 
EX11

EX12




