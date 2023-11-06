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

EX4:

EX5:

EX6:

EX7:

EX8:
