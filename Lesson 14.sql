---I. WINDOW FUNCTION with SUM(), COUNT(), AVG(), COUNT()
---1. OVER() WITH PARTITION BY 
/*Ví dụ 1: 
Tính tỷ lệ số tiền thanh toán từng ngày với tổng số tiền đã thanh toán của
mỗi khách hàng 
Output là: mã KH, tên KH, ngày thanh toán, số tiền thanh toán tại ngày, 
tổng số tiền đã thanh toán, tỷ lệ 
*/
--Cách 1:sử dụng subquery 
--bước1:
select a.customer_id, b.first_name, a.payment_date, 
a.amount, 
sum(amount)
from payment as a
join customer as b on a.customer_id=b.customer_id
group by a.customer_id, b.first_name, a.payment_date, 
a.amount;
--> kết quả sum(amount) vô nghĩa vì dữ liệu bị group by bởi 3 giá trị 

--bước2:
--> cần viết subquery để tính tổng số tiền chỉ group by bởi customer_id
select customer_id, sum(amount)
from payment
group by customer_id

--bước 3: gộp lại
select a.customer_id, b.first_name, a.payment_date, 
a.amount, 
(select sum(amount)
from payment as x
where x.customer_id = a.customer_id
group by customer_id) as sum
from payment as a
join customer as b on a.customer_id=b.customer_id;

--bước4: tính tỷ lệ 
select a.customer_id, b.first_name, a.payment_date, 
a.amount, 
(select sum(amount)
from payment as x
where x.customer_id = a.customer_id
group by customer_id) as sum,
a.amount/(select sum(amount)
from payment as x
where x.customer_id = a.customer_id
group by customer_id) as ty_le
from payment as a
join customer as b on a.customer_id=b.customer_id;

--Cách 2: sử dụng cte: trường nào chưa có sẵn thì nên tính toán và để vào 
từng cte

with twt_total_payment as
(
select customer_id, sum(amount) as total
from payment
group by customer_id
)
select a.customer_id, b.first_name, a.payment_date, 
a.amount,c.total, a.amount/c.total as ty_le
from payment as a
join customer as b on a.customer_id=b.customer_id
join twt_total_payment as c on c.customer_id=a.customer_id

--Cách 3: sử dụng window function 

select a.customer_id, b.first_name, a.payment_date, 
a.amount, 
sum(a.amount) over(partition by a.customer_id) as total,
a.amount/sum(a.amount) over(partition by a.customer_id) as ty_le
from payment as a
join customer as b on a.customer_id=b.customer_id
;


--Cú pháp
SELECT col1, col2, col3...
AGG(col2) OVER(PARTITION BY col1, col2)
FROM table_name

/*
challenge 1: Viết truy vấn trả về danh sách phim bao gồm
film_id, title, length, category, thời lượng trung bình của phim trong 
category đó
sắp xếp kết quả theo film_id
*/

select a.film_id, a.title, a.length,
c.name as category, 
round(avg(a.length) over(partition by c.name),2) as avg
from film a
join film_category as b on a.film_id=b.film_id
join category as c on c.category_id =b.category_id
order by a.film_id ;

/* challenge 2: 
Viết truy vấn trả về tất cả chi tiết các thanh toán bao gồm 
số lần thanh toán được thực hiện bởi khách hàng này và số tiền đó
sắp xếp kết quả theo payment_id
*/

select 
*, 
count(payment_id) over(partition by customer_id, amount) as count
from payment
order by payment_id;

---2. OVER() WITH ORDER BY
--sắp xếp theo chiều dữ liệu từ xa đến gần của ngày thanh toán và cộng luỹ 
kế tất cả dữ liệu thời điểm trước đấy cộng với dữ liệu thời điểm hiện tại 
/*
Tính lũy kế từ số liệu trước đấy về thời điểm hiện tại
sắp xếp theo chiều  tăng dần của payment_date, dữ liệu từ xa đến gần của ngày thanh toán.
Sau đấy cộng luỹ kế tất cả dữ liệu của các ngày trước đấy trước đấy 
cộng với dữ liệu thời điểm hiện tại 
*/

select payment_date, amount,
sum(amount) over(order by payment_date) as luy_ke
from payment;

---kết hợp với partition by để tính tổng chi tiêu lũy kế theo từng khách
select payment_date, customer_id, amount,
sum(amount) over(partition by customer_id order by payment_date) as luy_ke
from payment

--cú pháp
SELECT col1, col2, coln..,
AGG(col2) OVER(PARTITION BY col1, col2,... ORDER BY col3)
FROM table_name

---II. WINDOW FUNCTION with RANK FUNCTION
-- sử dụng window function để có thể xếp hạng theo một cụm dữ liệu/một window
Phân nhóm theo từng cụm, rồi xếp hạng dữ liệu theo tiêu chí bất kỳ 
trong từng cụm  
-- Nếu chỉ cần xếp hạng mà không cần phân nhóm/cụm, thì bỏ cụm PARTITION BY, chỉ 
cần dùng luôn ORDER BY 
/*
Ví dụ: xếp hạng độ dài phim trong từng thể loại
output: film_id, category name, length, xếp hạng độ dài phim trong từng 
category
*/
select a.film_id,c.name as category, a.length,
rank() over(partition by c.name order by a.length desc) as rank1,
dense_rank() over(partition by c.name order by a.length desc) as rank2,
row_number() over(partition by c.name order by a.length desc) as rank3
from film a
join film_category as b on a.film_id=b.film_id
join category as c on c.category_id =b.category_id;

--rank() không sử dụng số thứ tự gối tiếp 

--dense_rank() được dùng để tạo số thứ tự dạng gối tiếp, 
--số thứ tự sẽ luôn có đủ 1,2,3,4,5 dù có trùng số thứ tự

--row_number() sắp xếp theo thứ tự từ 1,2,3,4,... 
--mà không có số thự tự trùng nhau 

select a.film_id,c.name as category, a.length,
rank() over(partition by c.name order by a.length desc) as rank1,
dense_rank() over(partition by c.name order by a.length desc) as rank2,
row_number() over(partition by c.name order by a.length desc) as rank3
from film a
join film_category as b on a.film_id=b.film_id
join category as c on c.category_id =b.category_id;

-- row_number() nếu có 2 phim trong cùng category có cùng thời lượng thì 
--số thứ tự được trao random
-- row_number() tránh số thứ tự được trao random cho phim trong cùng 
--category có cùng thời lượng, thì thêm điều kiện sắp xếp 
select a.film_id, c.name as category, a.length,
row_number() over(partition by c.name order by a.length desc, a.film_id) 
as rank3
from film a
join film_category as b on a.film_id=b.film_id
join category as c on c.category_id =b.category_id;


/*
Challenge: viết truy vấn trả về tên khách hàng, quốc gia và 
số lượng thanh toán mà họ có
Sau đó tạo bảng xếp hạng những khách hàng có doanh thu cao nhất cho 
mỗi quốc gia
Lọc kết quả chỉ 3 khách hàng hàng đầu của mỗi quốc gia
*/
--task1
select a.first_name ||' ' ||a.last_name as full_name,
d.country, count(*) as so_luong
from customer a
join address b on a.address_id =b.address_id
join city c on b.city_id=c.city_id
join country d on c.country_id=d.country_id
join payment e on a.customer_id =e.customer_id
group by a.first_name ||' ' ||a.last_name,
d.country

-task2
select * from 
(select a.first_name ||' ' ||a.last_name as full_name,
d.country, count(*) as so_luong, sum(e.amount) as amount,
rank() over (partition by d.country order by sum(e.amount) desc ) as stt
from customer a
join address b on a.address_id =b.address_id
join city c on b.city_id=c.city_id
join country d on c.country_id=d.country_id
join payment e on a.customer_id =e.customer_id
group by a.first_name ||' ' ||a.last_name,
d.country) as t
where t.stt<=3


---III. WINDOW FUNCTION with FIRST_VALUE
--Ví dụ: Số tiền thanh toán cho đơn hàng đầu tiên và gần đây nhất của
từng khách hàng 
--cách 1
-- ngày đầu tiên
select *
from 
(select customer_id,amount,payment_date,
row_number() over(partition by customer_id order by payment_date) as stt
from payment ) 
where stt = 1

--ngày gần nhất
select *
from 
(select customer_id,amount,payment_date,
row_number() over(partition by customer_id order by payment_date desc) as stt
from payment ) 
where stt = 1

--cách 2
select customer_id,payment_date,amount,
first_value(amount) over(partition by customer_id order by payment_date) as first_amount,
first_value(amount) over(partition by customer_id order by payment_date desc) as last_amount
from payment

--phân nhóm theo từng customer_id trước, trong cùng 1 customer_id sẽ order by
theo payment_date, sau đấy lấy first_value tức dòng đầu tiên của cột amount
sau khi đã sắp xếp tệp dữ liệu 

---IV.WINDOW FUNCTIONS with LEAD(), LAG()
--Ví dụ: tìm chênh lệch giữa hai lần thanh toán liên tiếp của từng khách hàng
--SQL chỉ cho phép cộng trừ nhân chia theo chiều ngang,
--Không thể cộng trừ nhân chia theo chiều dọc 
--> Lead() đẩy số tiền của (ngày tiếp theo của ngày x) lên ngang hàng với số tiền (ngày x)
--> sau đó tìm chênh lệch bằng cách thực hiện phép trừ cột amount với cột next_amount
	
select customer_id, payment_date, amount,
lead (amount) over(partition by customer_id order by payment_date) as next_amount,
lead(payment_date) over(partition by customer_id order by payment_date) as next_payment_date,
amount-lead (amount) over(partition by customer_id order by payment_date) as diff
from payment


--Ví dụ:  tìm chênh lệch giữa số tiền thanh toán của payment_date đầu với
số tiền thanh toán của payment_date khác-mà cách payment_date đầu 3 lần 
mua hàng

select customer_id, payment_date, amount,
lead (amount,3) over(partition by customer_id order by payment_date) as next_amount,
lead(payment_date,3) over(partition by customer_id order by payment_date) as next_payment_date,
amount-lead (amount,3) over(partition by customer_id order by payment_date) as diff
from payment

--> lead() cho phép chúng ta tạo thêm một cột giá trị mới mà cột giá trị 
này mang dữ liệu là dữ liệu tiếp theo so với dòng dữ liệu hiện tại đang có


-->lag()cho phép chúng ta tạo thêm một cột giá trị mới mà cột giá trị 
này mang dữ liệu là dữ liệu trước đấy so với dòng dữ liệu hiện tại đang có
select customer_id, payment_date, amount,
lag (amount) over(partition by customer_id order by payment_date) as previous_amount,
lag(payment_date) over(partition by customer_id order by payment_date) as previous_payment_date,
amount-lag (amount) over(partition by customer_id order by payment_date) as diff
from payment

--> nếu không muốn gom nhóm hay phân cụm theo khách hàng nào, chỉ cần bỏ
--partition by. Dữ liệu sẽ được sắp xếp theo payment_date

select payment_date, amount,
lag (amount) over(order by payment_date) as previous_amount,
lag(payment_date) over(order by payment_date) as previous_payment_date,
amount-lag (amount) over(order by payment_date) as diff
from payment

/*
Challenge 1: Viết truy vấn trả về doanh thu trong ngày và doanh thu của 
ngày hôm trước
Sau đó tính toán phần trăm tăng trưởng so với ngày hôm trước
*/

select payment_date, amount, 
lag(payment_date) over(order by payment_date) as previous_payment_date,
lag(amount) over(order by payment_date) as previous_amount,
round(
	((amount-lag(amount) over(order by payment_date))
	  /lag(amount) over(order by payment_date))*100,2
					   ) as diff
from
(select date(payment_date) as payment_date, sum(amount)as amount
from payment
group by date(payment_date)) as t












