ex1
select
a.CONTINENT, FLOOR(AVG(b.POPULATION))
from COUNTRY as a
INNER join CITY as b
ON a.CODE =b.COUNTRYCODE
GROUP BY a.CONTINENT

ex2
SELECT 
ROUND(CAST(SUM(CASE 
WHEN b.signup_action='Confirmed' THEN 1
ELSE 0
END) AS DECIMAL)/
CAST(COUNT(DISTINCT a.user_id) AS DECIMAL), 2)
FROM emails as a
join texts as b
on a.email_id=b.email_id;

ex3 
SELECT 
a.age_bucket,
round(sum(case
when b.activity_type = 'send' then b.time_spent
else 0 
END)/sum(case 
when b.activity_type in ('send','open') then b.time_spent
else 0 
END) * 100.0, 2) as send_perc,
round(sum(case
when b.activity_type = 'open' then b.time_spent
else 0 
END)/sum(case 
when b.activity_type in ('send','open') then b.time_spent
else 0 
END)*100.0, 2) as open_perc
FROM age_breakdown as a
left join activities AS b 
on a.user_id=b.user_id 
group by a.age_bucket
order by a.age_bucket; 


ex4 
SELECT a.customer_id
FROM customer_contracts as a
join products as b
on a.product_id=b.product_id
where left(b.product_name,5) ='Azure'
GROUP BY a.customer_id
having count(distinct b.product_category) = 3;
  
ex5
select b.employee_id, b.name , count(*) as reports_count, ceiling(avg(a.age)) as average_age
from Employees as a
left join Employees as b 
on  a.reports_to= b.employee_id
where b.name is not null
group by b.employee_id, b.name

ex6,
select a.product_name, sum(b.unit) as unit
from Products as a
join Orders as b
on a.product_id =b.product_id 
where b.order_date between '2020-02-01' and '2020-02-29'
group by a.product_name
having sum(b.unit) >=100

ex7
SELECT a.page_id
FROM pages as a
join page_likes as b 
on a.page_id=b.page_id
group by a.page_id
having count(b.user_id) =0
order by a.page_id;

câu hỏi 1
select distinct replacement_cost
from film
order by replacement_cost;

câu hỏi 2
select 
case
when replacement_cost between 9.99 and 19.99 then 'low'
end,
count(*) 
from film
where 
(case
when replacement_cost between 9.99 and 19.99 then 'low'
end) is not null
group by case
when replacement_cost between 9.99 and 19.99 then 'low'
end ;

câu hỏi 3
select 
a.title,a.length,c.name
from public.film as a
join public.film_category as b on a.film_id=b.film_id
join public.category as c on b.category_id=c.category_id
where c.name in ('Drama','Sports')
order by a.length desc
limit 10;

câu hỏi 4
select 
c.name, count(a.title)
from public.film as a
join public.film_category as b on a.film_id=b.film_id
join public.category as c on b.category_id=c.category_id
group by c.name
order by count(a.title) desc 
limit 10;

câu hỏi 5
select a.first_name, a.last_name, count(b.film_id)
from actor as a
join film_actor as b
on a.actor_id = b.actor_id
group by a.first_name, a.last_name
order by count(b.film_id) desc
limit 10;

câu hỏi 6
select count(*)
from address as a
full join customer as b
on a.address_id = b.address_id
where customer_id is null;

câu hỏi 7
select a.city, sum(d.amount)
from city as a
join public.address as b on a.city_id = b.city_id
join public.customer as c on b.address_id=c.address_id
join public.payment as d on c.customer_id=d.customer_id
group by a.city
order by sum(d.amount) desc
limit 10;

câu hỏi 8 -- câu này mình ra kết quả giống câu 7
select a.city || ', ' || e.country, sum(d.amount)
from city as a
join public.address as b on a.city_id = b.city_id
join public.customer as c on b.address_id= c.address_id
join public.payment as d on c.customer_id= d.customer_id
join public.country as e on a.country_id= e.country_id
group by a.city || ', ' || e.country
order by sum(d.amount)
limit 10;
