---HÀM TỔNG HỢP AGGREGATE FUNCTION
SELECT
max(amount) as max_amount,
min(amount) as min_amount,
sum(amount) as total_amount,
avg(amount) as average_amount,
count(*) as total_record,
count(distinct customer_id) as total_record_customer
FROM payment
where payment_date between '2020-01-01' and '2020-02-01'
and amount >0;


---GROUP BY
/*cho biết số lượng đơn hàng của mỗi khách hàng là 
bao nhiêu */
select customer_id, staff_id, 
sum(amount) as amount_total,
avg(amount) as average_amount,
max(amount) as max_amount,
min(amount) as min_amount,
count(*) as count_order
from payment
group by customer_id, staff_id
order by customer_id

/*cú pháp*/
select col1, col2,
sum(), avg(), max(), min()
from table_nm
group by col1, col2

/* xem thông số về bộ phim: tối đa, tối thiểu, trung bình,
tổng về chi phí thay thế các film hiện tại của công ty.
Với chi phí thay thế một tài sản là chi phí để mua mới
một tài sản có giá trị tương đương với tài sản đó*/
select
film_id,
max(replacement_cost) as max_cost,
min(replacement_cost) as min_cost,
round(avg(replacement_cost),2) as average_cost,
sum(replacement_cost) as total_cost
from film
group by film_id
order by film_id


--- HAVING
-- tìm khách hàng đã trả tổng số tiền >100$
select customer_id,
sum(amount) as total_amount
from payment
where payment_date between '2020-01-01' and '2020-02-01'
group by customer_id
having sum(amount) >10
order by customer_id
-- HAVING vs WHERE
/* 
WHERE lọc điều kiện trên những trường có sẵn
HAVING lọc điều kiện trên những trường thông tin 
tổng hợp, ví dụ trường thông tin sử dụng hàm sum,
max, min, avg, count.
HAVING luôn đứng sau GROUP BY, sau khi góp nhóm
,vì HAVING chỉ sử dụng khi tổng hợp dữ liệu 
*/

/*năm 2020, ngày 28,29, 30/04 là những ngày có
doanh thu rất cao. Tìm số tiền thanh toán trung 
bình được nhóm theo khách hàng và ngày thanh toán 
chỉ xem những khách hàng có nhiều hơn 1 khoản thanh toán
sắp xếp số tiền trung bình theo thứ tự giảm dần*/
select customer_id, 
date(payment_date),
round(avg(amount),2) as average_amount,
count(customer_id)
from payment
where date(payment_date) in ('2020-04-28', '2020-04-29', '2020-04-30')
group by customer_id, date(payment_date)
having count(customer_id) >1
order by avg(amount) desc



--- Toán tử và hàm số học
select 3+7, 3-7, 3*7, 3/7, 7%3, 7^3

select film_id, rental_rate,
round(rental_rate*1.1,2) as new_rental_rate,
ceiling(rental_rate*1.1), 
floor(rental_rate*1.1)
from film

/*tạo danh sách các bộ phim có giá thuê ít hơn 4%
chi phí thay thế. Lập danh sách film_id, tỷ lệ phần 
trăm (giá thuê/chi phí thay thế) làm tròn đến 2 chữ 
số thập phân */
select film_id, 
rental_rate,
replacement_cost,
round(rental_rate/replacement_cost*100,2) 
from film
where round(rental_rate/replacement_cost*100,2) <4
