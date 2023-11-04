EX1:
select year, product_id, curr_year_spend,
lag(curr_year_spend) over(partition by product_id order by year) as prev_year_spend,
round(((curr_year_spend-lag(curr_year_spend) over(partition by product_id order by year))
/lag(curr_year_spend) over(partition by product_id order by year))*100,2) as yoy_rate
FROM
(SELECT
extract(year from transaction_date) as year, product_id, sum(spend) as curr_year_spend
FROM user_transactions
group by extract(year from transaction_date), product_id) as t
;

EX2:
SELECT distinct card_name,
first_value(issued_amount) OVER(partition by card_name order by issue_year, issue_month)
as 	issued_amount
FROM monthly_cards_issued
order by issued_amount DESC;

EX3:
select user_id, spend, transaction_date
from 
(SELECT *,
rank() over(partition by user_id order by transaction_date) as rank 
FROM transactions) as t
where rank=3;

EX4:
SELECT transaction_date, user_id, count(product_id)
FROM
(SELECT max(transaction_date) over(partition by user_id) as recent_transaction_date,*
FROM user_transactions) as t
where recent_transaction_date=transaction_date
group by transaction_date, user_id
;

EX5:
with cte as
(SELECT *, 
lag(tweet_count) over(partition by user_id order by tweet_date) as previous_tweet_count,
lag(tweet_count,2) over(partition by user_id order by tweet_date) as thedaybefore_tweet_count
FROM tweets),
cte1 AS
(
select * ,
(case when tweet_count is not null then 1
else 0
end) as count1,
(case when previous_tweet_count is not null then 1
else 0
end) as count2,
(case when thedaybefore_tweet_count is not null then 1
else 0
end) as count3
from cte),
cte2 AS
(
select user_id, tweet_date, tweet_count, COALESCE(previous_tweet_count,'0') as previous_tweet_count,
COALESCE(thedaybefore_tweet_count,'0') as thedaybefore_tweet_count,
count1,count2,count3
from cte1)
select 
user_id, tweet_date, 
round(
cast(tweet_count+ previous_tweet_count + thedaybefore_tweet_count as decimal)
/cast (count1 +count2+count3 as decimal) ,2) as rolling_avg_3d
from cte2;

EX6:
with cte as 
(SELECT merchant_id, credit_card_id, amount, 
transaction_timestamp, 
lead(transaction_timestamp) over(partition by merchant_id, credit_card_id, amount order by transaction_timestamp) as next_transaction_timestamp,
lead(transaction_timestamp) over(partition by merchant_id, credit_card_id, amount order by transaction_timestamp) - transaction_timestamp as diff
FROM transactions),
cte1 as --chuyển đổi chênh lệch sang phút
(
select *,
extract(day from diff) *24*60 +extract(hour from diff)*60 +extract(minute from diff) as diff_minute
from cte
)
SELECT
count(diff_minute) as payment_count
from cte1
where diff_minute between 0 and 10;

EX7:
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

EX8: 
with cte as 
(
SELECT
artist_name,appearance,
dense_rank() over(order by appearance desc) as artist_rank 
FROM
(SELECT a.artist_name as artist_name,
SUM(CASE
when rank between 1 and 10 then 1
else 0
END) as appearance 
FROM artists AS a 
join songs as b on a.artist_id=b.artist_id 
join global_song_rank as c on c.song_id=b.song_id
group by a.artist_name) as t
)
select artist_name, artist_rank 
from cte
where artist_rank between 1 and 5
;
