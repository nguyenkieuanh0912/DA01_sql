---1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng
with cte as
(
   select
*
from
(
select 
FORMAT_DATE('%Y-%m', created_at) as month_year,
user_id, order_id,status
from bigquery-public-data.thelook_ecommerce.order_items) as a
where status ="Complete" and month_year between '2019-01' and  '2022-04'
)
select cte.month_year,
count(user_id) as total_user,
count(order_id) as total_order
from cte
group by cte.month_year
order by cte.month_year

--- Số lượng người mua và số lượng đơn hàng hoàn thành mỗi tháng là tăng dần theo thời gian từ 01/2019 đến 04/2024. Số lượng người dùng và số lượng đơn hàng trong thời gian này gần như bằng nhau, tương đương mỗi khách hàng sẽ mua một đơn hàng hàng tháng. Số lượng đơn hàng tăng lên do số lượng người mua tăng.

---2. Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
select month_year, 
count(distinct user_id) as distinct_users, 
round(sum(sale_price)/count(order_id),2) as average_order_value
from 
(select 
FORMAT_DATE('%Y-%m', created_at) as month_year,
user_id, order_id,sale_price
from bigquery-public-data.thelook_ecommerce.order_items ) a
where month_year between '2019-01' and  '2022-04'
group by month_year
order by month_year
----Theo thời gian số lượng khách hàng tăng dần lên từ 18 khách tại thời điểm t1/2019 đến 2171 khách tại thời điểm t4/2022. Tuy nhiên giá trị trung bình một đơn hàng là không thay đổi nên doanh thu tăng là do sự tăng lên của khách hàng tham gia. Có thẻ xem xét các chương trình, campain để tăng mức mua sắm trung bình của một khách, nhằm tăng giá trị trung bình. 
Ví dụ chính sách tặng qùa cho những đơn hàng đạt được giá trị 80$ trở lên (do mức giá trị trung bình chỉ thay đổi xung quanh mốc 50-60$)

---3.Nhóm khách hàng theo độ tuổi
begin
create temp table tmp_age_group as
with cte as
(select first_name, last_name, age, gender, 
rank() over (partition by gender order by age ) as thu_tu_be,
rank() over (partition by gender order by age desc ) as thu_tu_lon
from bigquery-public-data.thelook_ecommerce.users
where created_at between '2019-01-01' and '2022-05-01'
)
select first_name, last_name, gender, age,"oldest" as tag
from cte
where thu_tu_lon =1 
union all
select first_name, last_name, gender, age,"youngest" as tag
from cte
where thu_tu_be =1;
end;
SELECT tag,age, count(first_name) as so_luong
FROM `copper-freedom-383808._scriptf5b828e6b3febc4f127658d8dde8abbe9d8760c0.tmp_age_group` 
group by tag,age
---Khách hàng trẻ nhất là 12 tuổi và có 1157 khách hàng ở độ tuổi này. Khách hàng lớn tuổi nhất là 70 tuổi và có 1088 khách hàng ở độ tuổi này

---4.Top 5 sản phẩm mỗi tháng.
with cte as(
select month_year, product_id, product_name, 
retail_price, cost, count(*) as so_luong
from 
(
select 
FORMAT_DATE('%Y-%m', a.created_at) as month_year,
a.product_id, 
b.name as product_name,
b.retail_price,
b.cost
from bigquery-public-data.thelook_ecommerce.order_items a
join bigquery-public-data.thelook_ecommerce.products b on a.product_id=b.id) a
group by month_year, product_id, product_name, retail_price, cost),
cte1 as (
select month_year, product_id,product_name, 
round(retail_price *so_luong,2) as sales, 
round(cost*so_luong,2) as cost, 
round((retail_price -cost) *so_luong,2) as profit,
dense_rank() over(partition by month_year order by (retail_price -cost) *so_luong desc) as rank_per_month 
from cte)
select *
from cte1
where rank_per_month between 1 and 5
order by month_year


---5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
select dates, product_categories, round(sum (retail_price),2) as revenue
from
(
select 
  date(a.created_at) as dates, 
  b.category as product_categories, 
  b.retail_price
from bigquery-public-data.thelook_ecommerce.order_items as a
join bigquery-public-data.thelook_ecommerce.products b on a.product_id=b.id
where cast(a.created_at as date) between date_add('2022-04-15', interval -90 day) and cast ('2022-04-15' as date)
) as a
group by dates, product_categories
