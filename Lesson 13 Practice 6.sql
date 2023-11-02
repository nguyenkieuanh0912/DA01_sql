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
select employee_id, department_id from Employee where primary_flag ='Y'
union
select employee_id, department_id from Employee GROUP BY employee_id having count(department_id) =1;

EX11
select * from (select b.name as results from MovieRating a join Users b on a.user_id=b.user_id group by a.user_id order by count(a.rating) desc, b.name limit 1) as table_1
union all
select * from (select c.title from Movies c join MovieRating a on a.movie_id =c.movie_id  where extract(month from created_at) =2 and extract(year from created_at )=2020 group by c.title order by avg(a.rating) desc, c.title limit 1) as table_2;
  
EX12
with cte1 as 
(select * from (select requester_id as id, accepter_id as friend from RequestAccepted
order by requester_id, accepter_id) as t1
union all 
select * from (select accepter_id as id, requester_id as friend from RequestAccepted
order by accepter_id, requester_id) as t2)
select distinct id, count(friend) as num
from cte1
group by id
order by count(friend) desc 
limit 1 



