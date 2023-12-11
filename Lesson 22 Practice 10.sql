---1, Tạo dataset * Không sử dụng được create view as để tạo View, mà dùng nút Save View ở dòng đầu tab Query 
with cte1 as --- metrics từ 1-5
(
  select 
  FORMAT_DATE('%Y-%m', a.created_at) as month_year,
  extract(year from a.created_at) as year,
  c.category, 
  round(sum(b.sale_price),2) as TPV,
  count(distinct b.order_id) as TPO,
  from bigquery-public-data.thelook_ecommerce.orders a 
  join bigquery-public-data.thelook_ecommerce.order_items b on a.order_id= b.order_id
  join bigquery-public-data.thelook_ecommerce.products c on b.product_id =c.id
  group by FORMAT_DATE('%Y-%m', a.created_at), extract(year from a.created_at), c.category
),
cte2 as ---metric 6, 7
(
  select month_year, year, category, TPV,
  lag (TPV) over(partition by category order by month_year) as previous_TPV,
   TPO,lag (TPO) over(partition by category order by month_year) as previous_TPO,
  round(((TPV-lag (TPV) over(partition by category order by month_year))/lag (TPV) over(partition by category order by month_year)) *100,2) || '%' as revenue_growth,
  round((TPO -lag (TPO) over(partition by category order by month_year))/lag (TPO) over(partition by category order by month_year)*100,2) || '%'  as order_growth
  from cte1
  order by category, month_year
),
cte3 as -- chuẩn bị dữ liệu tính metric 8
(
  select month_year, category, product_id, 
  retail_price, cost, count(product_id) as so_luong
  from 
  (
  select 
  FORMAT_DATE('%Y-%m', a.created_at) as month_year,
  a.product_id, 
  b.category,
  b.retail_price,
  b.cost
  from bigquery-public-data.thelook_ecommerce.order_items a
  join bigquery-public-data.thelook_ecommerce.products b on a.product_id=b.id) a
  group by month_year, category, product_id, retail_price, cost
  order by category, month_year, cost asc
),
cte4 as --tính metric 8
(
  select
  month_year, category, 
  round(sum(retail_price *so_luong),2) as doanh_thu, 
  round(sum(cost*so_luong),2) as chi_phi
  from cte3
  group by month_year, category
  order by category, month_year
)
  ---trình bày tất cả 10 metrics
select a.month_year, a.year,a.category, a.TPV, a.TPO, a.revenue_growth as Revenue_growth, a.order_growth as Order_growth, b.chi_phi as Total_cost,
round(a.TPV-b.chi_phi,2) as Total_profit, 
round(a.TPV/b.chi_phi,2) as Profit_to_cost_ratio
from cte2 a
join cte4 b on a. month_year =b.month_year and a.category=b.category
order by a.category, a.month_year
;

---2. Tạo retention cohort analysis.
with cte as
(
select
user_id, 
FORMAT_DATE('%Y-%m', created_at) as cohort_date,
(extract(year from created_at) - extract(year from first_purchase_date))*12 +
extract(month from created_at) - extract(month from first_purchase_date) +1 as index
from
(
SELECT created_at, user_id,
min(created_at) over (partition by user_id) as first_purchase_date
FROM `bigquery-public-data.thelook_ecommerce.orders` 
order by user_id, date(created_at)) a)
select cohort_date, index, count(distinct user_id) as number_of_customer
from cte
where index between 1 and 4
group by cohort_date, index
order by cohort_date, index
---link Google Sheets chứa bảng cohort
https://docs.google.com/spreadsheets/d/1r8dpR-cxjGgM-k4Ac4n3otnMM15Rh88xCRMdekoQDQg/edit?usp=sharing
