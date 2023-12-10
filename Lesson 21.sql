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

