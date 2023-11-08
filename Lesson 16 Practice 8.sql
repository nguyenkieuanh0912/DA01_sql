EX1:
select
round(cast(sum(case
when order_date = customer_pref_delivery_date then 1
else 0
end) as decimal)*100/cast(count(*) as decimal),2) as immediate_percentage
from 
(select *,
rank() over (partition by customer_id order by order_date) as first_order_date
from Delivery) as t
where first_order_date=1;

EX2:-- gặp vấn đề chỉ 13 / 14 testcases passed
with cte as
(select *,
lead(event_date) over(partition by player_id order by event_date) as next_date, 
rank() over ( partition by player_id order by event_date) as rank123,
cast(lead(event_date) over(partition by player_id order by event_date) -event_date as decimal)  as diff
from Activity),
cte1 as 
(select 
count(*) as number_of_consecutive_player , (select count(distinct player_id) from Activity) as number_of_player
from cte
where rank123 =1 and diff =1)
select 
round(number_of_consecutive_player/number_of_player,2) as fraction 
from cte1

EX3:
with cte as
(select *,
case
when (id % 2) <> 0 then lead(student) over(order by id)
when (id % 2) = 0 then lag(student) over(order by id)
end as new_student
from Seat)
select id, 
coalesce (new_student,student) as student
from cte

EX4:
select visited_on , amount1+amount2+amount3+amount4+amount5+amount6+amount7 as amount,
round((amount1+amount2+amount3+amount4+amount5+amount6+amount7)/7,2) as average_amount
from
(select 
visited_on, 
sum(amount) as amount1, 
lag(sum(amount)) over (order by visited_on) as amount2,
lag(sum(amount),2) over (order by visited_on) as amount3,
lag(sum(amount),3) over (order by visited_on) as amount4, 
lag(sum(amount), 4) over (order by visited_on) as amount5,
lag(sum(amount), 5) over (order by visited_on) as amount6, 
lag(sum(amount), 6) over (order by visited_on) as amount7
from Customer
group by visited_on) as t
where amount1 and amount2 and amount3 and amount4 and amount5 and amount6 and amount7 is not null 

EX5:
with dk1 as
(
 select pid, tiv_2016, tiv_2015, lat, lon 
 from Insurance
 where tiv_2015 in 
  (select tiv_2015 
  from Insurance 
  group by tiv_2015 
  having count(tiv_2015) >1)
), 
dk2 as 
(
  select pid, tiv_2016, tiv_2015, lat, lon 
  from Insurance
  where concat(lat,' ',lon) in 
    (select concat(lat,' ',lon)
    from Insurance 
    group by concat(lat,' ',lon)
    having count(concat(lat,' ',lon)) =1)
)
select round(sum(a.tiv_2016),2) as tiv_2016
from dk1 as a
join dk2 as b on a.pid=b.pid

  
EX6:
with cte as
(select a.name as Department, b.name as Employee, b.salary as Salary, 
dense_rank () over (partition by a.name order by b.salary desc )as thu_tu
from Department as a
join Employee as b on a.id  =b.departmentId)
select Department, Employee, Salary
from cte
where thu_tu in (1,2,3)
  
EX7:
select
distinct first_value(person_name) over( order by luy_ke desc) as person_name
from
(select *, sum(weight) over(order by turn) as luy_ke
from Queue
order by turn) as t
where luy_ke <=1000
  
EX8:
with cte as
(
select distinct product_id,
first_value (new_price) over(partition by product_id order by change_date desc) as price
from Products
where change_date <= '2019-08-16'
),
cte1 as
(
  select distinct product_id
  from Products
)
select b.product_id, coalesce(a.price, 10 )as price 
from cte as a
right join cte1 as b on a.product_id=b.product_id
