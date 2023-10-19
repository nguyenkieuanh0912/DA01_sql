ex1
SELECT 
sum(CASE
WHEN device_type = 'laptop' then 1 else 0
END) as laptop_reviews,
sum(CASE
WHEN device_type in ('tablet','phone') then 1 else 0
END) as mobile_views
FROM viewership;

ex2
select *,
case 
when x+y>z and x+z>y and y+z>x then 'Yes'
else 'No'
end as triangle
from Triangle;

ex3: datalemur-uncategorized-calls-percentage.
SELECT 
  ROUND(CAST(SUM(CASE
    WHEN call_category ='n/a' or call_category is null then 1
    ELSE 0
  END)/COUNT(*) AS DECIMAL),1)*100 AS call_percentage
FROM callers;

ex4
select name
from Customer 
where referee_id !=2 or referee_id is null;

ex5
select survived,
sum(case
    when pclass = 1 then 1
    else 0
end ) as first_class,
sum(case
    when pclass = 2 then 1
    else 0
end ) as second_class,
sum(case
    when pclass = 3 then 1
    else 0
end ) as third_class
from titanic
group by survived;
