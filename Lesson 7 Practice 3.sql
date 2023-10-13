ex1 
select Name from STUDENTS where Marks >75 order by right(Name,3), ID;

ex2
select
user_id,
Concat(upper(left(name,1)),lower(substring(name from 2))) as name
from Users
order by user_id;

ex3
SELECT 
manufacturer, '$' ||ceiling(sum(total_sales)/1000000) || ' million' as total_sales 
FROM pharmacy_sales
group by manufacturer
order by sum(total_sales) desc, manufacturer;

ex4
SELECT extract(month from submit_date) as month, product_id, round(avg(stars),2) 
FROM reviews
group by extract(month from submit_date), product_id 
order by extract(month from submit_date), product_id;

ex5
SELECT sender_id, count(message_id) 
FROM messages
where to_char(sent_date,'mm-yyyy') ='08-2022'
group by sender_id
order by count(message_id) desc
limit 2
;

ex6
select tweet_id
from Tweets
where length(content) > 15;

ex7
select activity_date as day, count(distinct user_id) as active_users
from Activity
where activity_date between '2019-06-28' and '2019-07-28'
group by activity_date
;

or
select activity_date as day, count(distinct user_id) as active_users 
from Activity
where activity_date between date_add('2019-07-27', interval -29 day) and '2019-07-27'
group by  activity_date


ex8
select count(id)
from employees
where extract(month from joining_date) between 1 and 7 
and extract(year from joining_date) = 2022
;

ex9
select position('a' in 'Amitah')
from worker
where first_name = 'Amitah' or last_name = 'Amitah';

ex10
select title, cast(substring( title from position(' ' in title )+1 for 4) as numeric) as year
from winemag_p2
where country = 'Macedonia';
