select * from online_retail

--bảng online_retail sẽ gọi là dataset. 
/*
Bước 1:Khám phá & Làm sạch dữ liệu
- Chúng ta đang quan tâm đến trường nào?
- Check null
- Chuyển đổi kiểu dữ liệu
- Số tiền và số lượng >0
- Check duplicate
*/
-- có 541909 bản ghi;135080 bản ghi có customerid null 
select count(*) from online_retail --kiểm tra xem có bao nhiêu bản ghi

select * from online_retail  -- kiểm tra null 
where invoiceno =''

select * from online_retail  
where stockcode =''

select * from online_retail  
where customerid =''

select count(*) from online_retail  -- đếm số lượng null
where customerid =''

select * from online_retail  -- lựa chọn các bản ghi có customerid khác null
where customerid <>''

-- chuyển đổi kiểu dữ liệu: invoiceno, stockcode, description có thể là varchar. Nhưng quantity đổi sang số, invoicedate sang dạng datetime, unitprice sang dạng số
select invoiceno,
stockcode,
description,
cast (quantity as int) as quantity , -- dạng integer
cast (invoicedate as timestamp) as invoicedate ,
cast (unitprice as numeric) as unitprice, -- ví nó là số thập phân
customerid,
country
from online_retail
where customerid <>''
and cast (quantity as int) >0 and cast (unitprice as numeric) >0 --lọc bản ghi có số tiền và số lượng >0 có thể nhầm do nhập sai
--chỉ có một invoiceno cho một thời điểm nhất định với nhiều mã mặt hàng nên mã mặt hàng trong cùng 1 đơn không được phép lặp 
--tạo bảng tạm để check duplicate

with online_retail_covert as
(
select invoiceno,
stockcode,
description,
cast (quantity as int) as quantity , 
cast (invoicedate as timestamp) as invoicedate ,
cast (unitprice as numeric) as unitprice, 
customerid,
country
from online_retail
where customerid <>''
and cast (quantity as int) >0 and cast (unitprice as numeric) >0 
)
select * from 
(select *,
row_number () over (partition by invoiceno, stockcode, quantity order by invoicedate) as stt
from online_retail_covert) as t
where stt>1 -- để tìm các bản ghi có stt lớn hơn 1, tức nó bị lặp

-- chọn những dòng dữ liệu không bị lặp, tức là stt =1

with online_retail_covert as
(
select invoiceno,
stockcode,
description,
cast (quantity as int) as quantity , 
cast (invoicedate as timestamp) as invoicedate ,
cast (unitprice as numeric) as unitprice, 
customerid,
country
from online_retail
where customerid <>''
and cast (quantity as int) >0 and cast (unitprice as numeric) >0 
)
select * from 
(select *,
row_number () over (partition by invoiceno, stockcode, quantity order by invoicedate) as stt
from online_retail_covert) as t
where stt=1;

-- lưu lại bảng dữ liệu 

with online_retail_covert as
(
select invoiceno,
stockcode,
description,
cast (quantity as int) as quantity , 
cast (invoicedate as timestamp) as invoicedate ,
cast (unitprice as numeric) as unitprice, 
customerid,
country
from online_retail
where customerid <>''
and cast (quantity as int) >0 and cast (unitprice as numeric) >0 
),
online_retail_main as
(
select * from 
(select *,
row_number () over (partition by invoiceno, stockcode, quantity order by invoicedate) as stt
from online_retail_covert) as t
where stt=1
)
select * from online_retail_main;



/*
Bước 2: 
- Tìm ngày mua hàng đầu tiên của mỗi KH => cohort date
- Tìm index = tháng (ngày mua hàng hiện tại- ngày mua hàng đầu tiên) +1
- Count số lượng Kh hoặc tổng doanh thu tại mỗi cohort date và index tương ứng 
- Pivot table
*/

with online_retail_covert as
(
select invoiceno,
stockcode,
description,
cast (quantity as int) as quantity , 
cast (invoicedate as timestamp) as invoicedate ,
cast (unitprice as numeric) as unitprice, 
customerid,
country
from online_retail
where customerid <>''
and cast (quantity as int) >0 and cast (unitprice as numeric) >0 
),
online_retail_main as
(
select * from 
(select *,
row_number () over (partition by invoiceno, stockcode, quantity order by invoicedate) as stt
from online_retail_covert) as t
where stt=1
),
-- thực hiện bước 2--- tính index: chênh lệch giữa 2 thời điểm bằng cách lấy (năm-năm)*12 tháng +(tháng -tháng)
online_retail_index as (
select customerid, amount,
to_char(first_purchase_date, 'yyyy-mm') as cohort_date,--tạo cohort date
(extract(year from invoicedate)- extract (year from first_purchase_date))*12 +
(extract (month from invoicedate)- extract (month from first_purchase_date)) +1 as index
 from
(select  
customerid, unitprice*quantity as amount,
min(invoicedate) over (partition by customerid) as first_purchase_date,
invoicedate
from online_retail_main) as a
)
select 
cohort_date,
index,
count(distinct customerid) as count,
sum(amount) as revenue
from online_retail_index 
group by cohort_date,
index

/*
Bước 3: Pivot table ==> cohort chart
*/


with online_retail_covert as
(
select invoiceno,
stockcode,
description,
cast (quantity as int) as quantity , 
cast (invoicedate as timestamp) as invoicedate ,
cast (unitprice as numeric) as unitprice, 
customerid,
country
from online_retail
where customerid <>''
and cast (quantity as int) >0 and cast (unitprice as numeric) >0 
),
online_retail_main as
(
select * from 
(select *,
row_number () over (partition by invoiceno, stockcode, quantity order by invoicedate) as stt
from online_retail_covert) as t
where stt=1
),
online_retail_index as (
select customerid, amount,
to_char(first_purchase_date, 'yyyy-mm') as cohort_date,--tạo cohort date
(extract(year from invoicedate)- extract (year from first_purchase_date))*12 +
(extract (month from invoicedate)- extract (month from first_purchase_date)) +1 as index
 from
(select  
customerid, unitprice*quantity as amount,
min(invoicedate) over (partition by customerid) as first_purchase_date,
invoicedate
from online_retail_main) as a
),
xxx as(
select 
cohort_date,
index,
count(distinct customerid) as count,
sum(amount) as revenue
from online_retail_index 
group by cohort_date,index)
--- index chạy từ 1 đến 13
--- bảng customer cohort
select 
cohort_date,
sum(case when index =1 then count else 0 end) as m1,
sum(case when index =2 then count else 0 end) as m2,
sum(case when index =3 then count else 0 end) as m3,
sum(case when index =4 then count else 0 end) as m4,
sum(case when index =5 then count else 0 end) as m5,
sum(case when index =6 then count else 0 end) as m6,
sum(case when index =7 then count else 0 end) as m7,
sum(case when index =8 then count else 0 end) as m8,
sum(case when index =9 then count else 0 end) as m9,
sum(case when index =10 then count else 0 end) as m10,
sum(case when index =11 then count else 0 end) as m11,
sum(case when index =12 then count else 0 end) as m12,
sum(case when index =13 then count else 0 end) as m13
from xxx
group by cohort_date

---retention cohort

with online_retail_covert as
(
select invoiceno,
stockcode,
description,
cast (quantity as int) as quantity , 
cast (invoicedate as timestamp) as invoicedate ,
cast (unitprice as numeric) as unitprice, 
customerid,
country
from online_retail
where customerid <>''
and cast (quantity as int) >0 and cast (unitprice as numeric) >0 
),
online_retail_main as
(
select * from 
(select *,
row_number () over (partition by invoiceno, stockcode, quantity order by invoicedate) as stt
from online_retail_covert) as t
where stt=1
),
online_retail_index as (
select customerid, amount,
to_char(first_purchase_date, 'yyyy-mm') as cohort_date,--tạo cohort date
(extract(year from invoicedate)- extract (year from first_purchase_date))*12 +
(extract (month from invoicedate)- extract (month from first_purchase_date)) +1 as index
 from
(select  
customerid, unitprice*quantity as amount,
min(invoicedate) over (partition by customerid) as first_purchase_date,
invoicedate
from online_retail_main) as a
),
xxx as(
select 
cohort_date,
index,
count(distinct customerid) as count,
sum(amount) as revenue
from online_retail_index 
group by cohort_date,index),
customer_cohort as
(select 
cohort_date,
sum(case when index =1 then count else 0 end) as m1,
sum(case when index =2 then count else 0 end) as m2,
sum(case when index =3 then count else 0 end) as m3,
sum(case when index =4 then count else 0 end) as m4,
sum(case when index =5 then count else 0 end) as m5,
sum(case when index =6 then count else 0 end) as m6,
sum(case when index =7 then count else 0 end) as m7,
sum(case when index =8 then count else 0 end) as m8,
sum(case when index =9 then count else 0 end) as m9,
sum(case when index =10 then count else 0 end) as m10,
sum(case when index =11 then count else 0 end) as m11,
sum(case when index =12 then count else 0 end) as m12,
sum(case when index =13 then count else 0 end) as m13
from xxx
group by cohort_date)

select cohort_date,
round(m1/m1*100.00,2) ||'%' as m1,
round(m2/m1*100.00,2) ||'%' as m2,
round(m3/m1*100.00,2) ||'%' as m3,
round(m4/m1*100.00,2) ||'%' as m4,
round(m5/m1*100.00,2) ||'%' as m5,
round(m6/m1*100.00,2) ||'%' as m6,
round(m7/m1*100.00,2) ||'%' as m7,
round(m8/m1*100.00,2) ||'%' as m8,
round(m9/m1*100.00,2) ||'%' as m9,
round(m10/m1*100.00,2) ||'%' as m10,
round(m11/m1*100.00,2) ||'%' as m11,
round(m12/m1*100.00,2) ||'%' as m12,
round(m13/m1*100.00,2) ||'%' as m13
from customer_cohort

---churn cohort
with online_retail_covert as
(
select invoiceno,
stockcode,
description,
cast (quantity as int) as quantity , 
cast (invoicedate as timestamp) as invoicedate ,
cast (unitprice as numeric) as unitprice, 
customerid,
country
from online_retail
where customerid <>''
and cast (quantity as int) >0 and cast (unitprice as numeric) >0 
),
online_retail_main as
(
select * from 
(select *,
row_number () over (partition by invoiceno, stockcode, quantity order by invoicedate) as stt
from online_retail_covert) as t
where stt=1
),
online_retail_index as (
select customerid, amount,
to_char(first_purchase_date, 'yyyy-mm') as cohort_date,--tạo cohort date
(extract(year from invoicedate)- extract (year from first_purchase_date))*12 +
(extract (month from invoicedate)- extract (month from first_purchase_date)) +1 as index
 from
(select  
customerid, unitprice*quantity as amount,
min(invoicedate) over (partition by customerid) as first_purchase_date,
invoicedate
from online_retail_main) as a
),
xxx as(
select 
cohort_date,
index,
count(distinct customerid) as count,
sum(amount) as revenue
from online_retail_index 
group by cohort_date,index),
customer_cohort as
(select 
cohort_date,
sum(case when index =1 then count else 0 end) as m1,
sum(case when index =2 then count else 0 end) as m2,
sum(case when index =3 then count else 0 end) as m3,
sum(case when index =4 then count else 0 end) as m4,
sum(case when index =5 then count else 0 end) as m5,
sum(case when index =6 then count else 0 end) as m6,
sum(case when index =7 then count else 0 end) as m7,
sum(case when index =8 then count else 0 end) as m8,
sum(case when index =9 then count else 0 end) as m9,
sum(case when index =10 then count else 0 end) as m10,
sum(case when index =11 then count else 0 end) as m11,
sum(case when index =12 then count else 0 end) as m12,
sum(case when index =13 then count else 0 end) as m13
from xxx
group by cohort_date)

select cohort_date,
(100-round(m1/m1*100.00,2)) ||'%' as m1,
(100-round(m2/m1*100.00,2)) ||'%' as m2,
(100-round(m3/m1*100.00,2)) ||'%' as m3,
(100-round(m4/m1*100.00,2)) ||'%' as m4,
(100-round(m5/m1*100.00,2)) ||'%' as m5,
(100-round(m6/m1*100.00,2)) ||'%' as m6,
(100-round(m7/m1*100.00,2)) ||'%' as m7,
(100-round(m8/m1*100.00,2)) ||'%' as m8,
(100-round(m9/m1*100.00,2)) ||'%' as m9,
(100-round(m10/m1*100.00,2)) ||'%' as m10,
(100-round(m11/m1*100.00,2)) ||'%' as m11,
(100-round(m12/m1*100.00,2)) ||'%' as m12,
(100-round(m13/m1*100.00,2)) ||'%' as m13
from customer_cohort



--- tải xuống excel 
with online_retail_covert as
(
select invoiceno,
stockcode,
description,
cast (quantity as int) as quantity , 
cast (invoicedate as timestamp) as invoicedate ,
cast (unitprice as numeric) as unitprice, 
customerid,
country
from online_retail
where customerid <>''
and cast (quantity as int) >0 and cast (unitprice as numeric) >0 
),
online_retail_main as
(
select * from 
(select *,
row_number () over (partition by invoiceno, stockcode, quantity order by invoicedate) as stt
from online_retail_covert) as t
where stt=1
),
online_retail_index as (
select customerid, amount,
to_char(first_purchase_date, 'yyyy-mm') as cohort_date,--tạo cohort date
(extract(year from invoicedate)- extract (year from first_purchase_date))*12 +
(extract (month from invoicedate)- extract (month from first_purchase_date)) +1 as index
 from
(select  
customerid, unitprice*quantity as amount,
min(invoicedate) over (partition by customerid) as first_purchase_date,
invoicedate
from online_retail_main) as a
)
select 
cohort_date,
index,
count(distinct customerid) as count,
sum(amount) as revenue
from online_retail_index 
group by cohort_date,index






