ex1
SELECT DISTINCT CITY FROM STATION WHERE MOD(ID,2) = 0;
hoặc
SELECT DISTINCT CITY FROM STATION WHERE ID%2 =0 -- nghĩa là id chia 2 dư 0

ex2
SELECT COUNT(CITY)-COUNT(DISTINCT CITY) FROM STATION;

ex3
SELECT CEILING(AVG(Salary)- AVG(REPLACE(Salary,'0',''))) FROM EMPLOYEES;

ex4
SELECT ROUND(cast(sum(order_occurrences * item_count)/sum(order_occurrences)) as decimal, 1) FROM items_per_order;

ex5
SELECT candidate_id
FROM  candidates
WHERE skill IN ('PostgreSQL', 'Python', 'Tableau') 
GROUP BY candidate_id
HAVING COUNT(candidate_id) =3
ORDER BY candidate_id ;  

ex6
SELECT user_id, MAX(date(post_date)), MIN(date(post_date)), MAX(date(post_date))-MIN(date(post_date)) as number_of_day
FROM posts
WHERE post_date >='2021-01-01' and post_date < '2022-01-01'
GROUP BY user_id
HAVING COUNT(post_id) >= 2;

ex7
SELECT 
card_name,
max(issued_amount)-min(issued_amount) as difference
FROM monthly_cards_issued
group by card_name
order by difference desc

ex8
SELECT 
manufacturer, count(drug) as count_drug,
abs(sum(total_sales)-sum(cogs)) as losses
FROM pharmacy_sales
where total_sales < cogs
group by manufacturer
order by losses desc;

ex9
select id, movie, description, rating
from Cinema
where mod(id,2) =1 and description not like '%boring%'
order by rating desc

hoặc
select *
from Cinema
where id%2 =1 and description <> 'boring'
order by rating desc 

ex10
select teacher_id, count(distinct subject_id) as cnt
from Teacher
group by teacher_id

ex11
select user_id, count(follower_id) as followers_count
from Followers
group by user_id
order by user_id

ex12
select 
class
from Courses
group by class
having count(student)>=5
