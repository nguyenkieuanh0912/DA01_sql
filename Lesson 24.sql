---1. Doanh thu theo từng ProductLine, Year và DealSize?
select productline, year_id, dealsize, sum(sales) as revenue
from public.sales_dataset_rfm_prj_clean
group by productline, year_id, dealsize

---2. Đâu là tháng có bán tốt nhất mỗi năm?
select year_id, month_id, revenue, order_number
from
(
select year_id, month_id, sum(sales) as revenue, count(distinct ordernumber) as order_number,
row_number() over(partition by year_id order by sum(sales) desc) as thu_tu
from public.sales_dataset_rfm_prj_clean
group by year_id, month_id) as a
where thu_tu=1 and year_id is not null 
---Trong năm 2003 tháng 11 là tháng có doanh thu tốt nhất với revenue là 1,029,837 và số lượng đơn đặt là 28
---Trong năm 2004 tháng 11 là tháng có doanh thu tốt nhất với revenue là 1,089,048 và số lượng đơn hàng là 33
---Trong năm 2005 tháng 5 là tháng có doanh thu tốt nhất với revenue là 440,123 và số lượng đơn hàng là 14
union all 
select  month_id, revenue, order_number
from
(
select  month_id, sum(sales)/count(distinct year_id) as revenue, count(distinct ordernumber)/count(distinct year_id) as order_number,
row_number() over( order by sum(sales) desc) as thu_tu
from public.sales_dataset_rfm_prj_clean
where year_id is not null
group by  month_id
 ) as a
where thu_tu=1 and month_id is not null 
--- Mỗi năm thì trung bình tháng 11 là tháng có doanh thu tốt nhất với revenue trung bình các năm là 1,059,442 và số lượng đơn hàng trung bình là 30

---3. Product line nào được bán nhiều ở tháng 11?
select month_id, productline, sum(sales) as revenue, count(distinct ordernumber) as order_number
from public.sales_dataset_rfm_prj_clean
where month_id=11
group by month_id, productline
order by sum(sales) desc 
limit 1
-- Ở tháng 11 của 3 năm thì Classic Cars là productline bán được nhiều nhất với revenue là 825,156 và số đơn đặt là 46

---4. Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? 
select year_id, productline, sum(sales) as revenue, rank() over(partition by year_id order by sum(sales) desc)
from public.sales_dataset_rfm_prj_clean
where country ='UK'
group by year_id, productline

--năm 2003, 2004 sản phẩm có doanh thu tốt nhất ở UK là Classic Cars với doanh thu là 66,705 và 92,762 tương ứng 
--năm 2005 sản phẩm có doanh thu tốt nhất ở UK là Motorcycles với doanh thu là 40,802

---5. Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
with customer_rfm as
(
select contactfullname, 
current_date- date(max(orderdate)) as R,
count(distinct ordernumber) as F,
sum(sales) as M
from public.sales_dataset_rfm_prj_clean
group by contactfullname)
,rfm_score as
(
select contactfullname, 
ntile(5) over (order by r desc) as R_score,
ntile(5) over (order by f) as F_score,
ntile(5) over (order by m) as M_score
from customer_rfm)
,rfm_final as
(
select contactfullname,
cast(R_score as varchar) || cast(F_score as varchar) || cast(M_score as varchar) as RFM_score 
from rfm_score)
select a.contactfullname, b.segment, a.rfm_score
from rfm_final a
join public.segment_score b on a. rfm_score= b.scores
where b.segment ='Champions'
order by a.contactfullname
--- Có 14 khách hàng tốt nhất, đạt được mốc Champions, là những người vừa có đơn hàng gần đây, thường xuyên mua hàng và tổng số lượng hàng hóa mua đạt mức lớn. 








