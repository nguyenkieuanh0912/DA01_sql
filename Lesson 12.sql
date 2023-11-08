--SUBQUERIES trong mệnh đề WHERE 
-- Tìm những hóa đơn có số tiền lớn hơn số tiền trung bình các hóa đơn

SELECT * FROM payment
WHERE amount > (SELECT AVG(amount) FROM payment)

-- Tìm những hóa đơn của khách hàng có tên là Adam
/*
B1: Tìm mã khách hàng của khách hàng có tên là Adam
B2: Tìm hóa đơn của khách hàng với mã khách là 367
*/

SELECT customer_id FROM customer WHERE first_name ='ADAM'
-- cho kết quả customer_id là 367
SELECT * FROM payment WHERE customer_id = 367

hoặc
SELECT * 
FROM payment 
WHERE customer_id =(SELECT customer_id FROM customer
					WHERE first_name ='ADAM')
--câu truy vấn con cho ra một kết quả duy nhất nên dùng '='

hoặc
SELECT * 
FROM payment 
WHERE customer_id IN (SELECT customer_id FROM customer)
-- sử dụng IN vì câu truy vấn con cho ra một list thay vì một kết quả duy nhất

hoặc 
SELECT a.* FROM payment as a
JOIN customer as b ON a.customer_id =b.customer_id
where b.first_name ='ADAM'

--CHALLENGE
/*
-Tìm ra những film có thời lượng lớn hơn trung bình các bộ phim
-trả kết quả film_id,title
*/
select film_id, title from film
where length>(select avg(length) from film)

/*
-Tìm ra những film có ở store 2 ít nhất 3 lần
-trả kết quả film_id, title
*/
select film_id, title from film
where film_id IN 
(select film_id from inventory where store_id =2 group by film_id having count(film_id)>= 3) 

/*
-Tìm ra những khách hàng đến từ California và đã chi tiêu nhiều hơn
100
-trả kết quả customer_id, first_name, last_name, email
*/

select customer_id,first_name, last_name, email 
from customer
where address_id in (select address_id from address 
					 where district='California')
and customer_id in (select customer_id 
					from payment 
					group by customer_id 
					having sum(amount)>100 )

-- SUBQUERIES trong mệnh đề FROM
--Tìm khách hàng có nhiều hơn 30 đơn hàng 
--b1: gom nhóm để liệt kê khách hàng và số lượng đơn hàng tương ứng 
-- SUBQUERIES sau mệnh đề FROM: Coi nó như một bảng mới và tính toán bình thường như các bảng khác
select customer_id, count(payment_id) as so_luong
from payment
group by customer_id
having count(payment_id) >30

hoặc 
select * from 
(select customer_id, count(payment_id) as so_luong
from payment
group by customer_id ) 
where so_luong >30

select customer.first_name, new_table.so_luong from 
(select customer_id, count(payment_id) as so_luong
from payment
group by customer_id ) as new_table
join customer on new_table.customer_id=customer.customer_id
where so_luong >30

--- SUBQUERIES sau mệnh đề SELECT

select *,
(select avg(amount)from payment),
(select avg(amount)from payment)- amount
from payment

select *,
(select amount from payment) 
--gặp lỗi vì không thể match list kết quả amount tương ứng với 
khách hàng nào--
from payment

-- -> cần phải limit 1 giá trị kết quả từ subqueries trong mệnh đề select
select *,
(select amount from payment limit 1) 
from payment

--hoặc dùng max() để kết quả trả ra trong câu truy vấn con là một giá trị
select *,
(select max(amount) from payment) 
from payment

/*
Tìm chênh lệch giữa số tiền từng hóa đơn so với số tiền thanh toán 
lớn nhất mà công ty nhận được
*/

select payment_id, amount, 
(select max(amount) from payment) as max_amount,
(select max(amount) from payment)-amount as diff
from payment

--CORRELATED QUERIES (truy vấn con tương quan )
--lấy ra thông tin khách hàng từ bảng customer có tổng hóa đơn >100

select a.customer_id,
sum(b.amount) as total
from customer as a
join payment as b on a.customer_id=b.customer_id
group by a.customer_id
having sum(b.amount) >100

hoặc
--B1: tìm danh sách khách hàng id có payment lớn hơn 100
select customer_id,
sum(amount)
from payment
group by customer_id
having sum(amount)>100

--B2: đi từ bảng customer
select * from customer
where customer_id in (select customer_id,
sum(amount)
from payment
group by customer_id
having sum(amount)>100)

--muốn sử dụng =
select * from customer as a
where customer_id = (select customer_id
from payment as b
where b.customer_id=a.customer_id--đảm bảo câu lệnh trả ra một kết quả duy nhất
group by customer_id
having sum(amount)>100)

hoặc
select * from customer as a
where EXISTS (select customer_id
from payment as b
where b.customer_id=a.customer_id--đảm bảo câu lệnh trả ra một kết quả duy nhất
group by customer_id
having sum(amount)>100)
--EXISTS chỉ sử dụng trong câu lệnh truy vấn con tương quan


---CORRELATED SUBQUERIES (truy vấn con tương quan)
--mã KH, tên KH, mã thanh toán, số tiền lớn nhất của từng khách hàng
select a.customer_id,
a.first_name || a.last_name,
b.payment_id,
max(b.amount)
from customer as a
join payment as b
on a.customer_id=b.customer_id
group by a.customer_id,
	a.first_name || a.last_name,
	b.payment_id
order by customer_id
-- -> kết quả k mong đợi

select 
customer_id, max(amount)
from payment
group by customer_id

-- sửa lại thành 

select a.customer_id,
a.first_name || a.last_name,
b.payment_id,
(select max(amount) from payment -- mệnh đề Select chỉ chấp nhận câu truy vấn con cho 1 kết quả duy nhất
 where customer_id=a.customer_id--thêm điều kiện để match các dòng dữ liệu của câu truy vấn con tương ứng với customer_id của bảng a nằm trong câu truy vấn bên dưới 
 group by customer_id)
from customer as a
join payment as b
on a.customer_id=b.customer_id
group by a.customer_id,
	a.first_name || a.last_name,
	b.payment_id
order by customer_id

--thêm điều kiện where rằng customer_id ở phần truy vấn con tương ứng
với customer_id nào ở phần câu truy vấn chính

/*
Liệt kê các khoản thanh toán với tổng số hóa đơn và tổng số tiền 
mỗi khách hàng phải trả
*/
select a.*,
(select sum(amount) 
 from payment as b
 where b.customer_id=a.customer_id
 group by customer_id) as sumt_amount,
(select count(*) 
 from payment b
 where b.customer_id=a.customer_id
 group by customer_id) as count_payments
from payment as a

hoặc
select a.*, b.count_payments, b.sum_amount
from payment as a
join (select customer_id, count(*) as count_payments,
sum(amount) as sum_amount
from payment
group by customer_id) as b
on a.customer_id=b.customer_id


/*
Lấy danh sách các film có chi phí thay thế lớn nhất trong mỗi loại rating
film_id, title, rating,replacement_cost, avg_replacement_cost
*/
select 
a.film_id, a.title, a.rating, a.replacement_cost,
 (select avg(replacement_cost) from film as b
  where b.rating = a.rating
  group by rating) as avg_replacement_cost
from film as a
where a.replacement_cost = (select max(replacement_cost) from film as c
							where c.rating =a.rating
							group by rating)


--subquery ở select liên quan đến hiển thị
--subquery ở where- liên quan đến lọc điều kiện

---CTE
/*
Cấu trúc gồm 4 phần
phần 1: bắt đầu bằng mệnh đề WITH
phần 2: tên chúng ta muốn đặt cho bảng dữ liệu tạm thời
phần 3: thân của mệnh đề WITH, thực hiện viết một câu lệnh SELECT hoàn chỉnh
Kết quả của câu lệnh sẽ được lưu vào bảng tạm vừa được đặt tên
phần 4: phần kết thúc của câu lệnh SQL, cũng như phần bắt buộc phải có. 
Nó là một câu lệnh SELECT hoàn chỉnh ngay sau CTE table, được viết ngay sau CTE body

--bảng CTE có thể được sử dụng nhiều lần ở nhiều nơi khác nhau mà không bị 
hạn chế số lượng miễn là đã được khai báo trước đó
--bảng CTE coi như một bảng bình đẳng với các bảng thông thường ở trong 
database, có thể sử dụng như một bảng bình thường với các câu lệnh JOIN, 
UNION, lọc điều kiện...

WITH high_payment AS
(
SELECT *
FROM payment
WHERE amount >10
)
SELECT * FROM hight_payment
*/

/*
Tìm khách hàng có nhiều hơn 30 hóa đơn.
Kết quả trả ra gồm các thông tin: mã KH, tên KH, số lượng hóa đơn, tổng
số tiền, thời gian thuê trung bình
*/
bảng cần là customer, payment, rental 
b1: với số lượng hóa đơn và tổng số tiền từ bảng payment
b2: tính thời gian thuê trung bình từ bảng rental
b3: đi đến câu lệnh chính với thông tin cần trả là customer id, tên kh từ
bảng customer
b4: nối bảng tạm với câu lệnh chính để lấy thông tin tổng số hóa đơn và 
tổng tiền 
b5: áp dụng điều kiện

--với số lượng hóa đơn và tổng số tiền từ bảng payment
with twt_total_payment as 
(select customer_id,
count(payment_id) as so_luong,
sum(amount) as so_tien
from payment
group by customer_id)

--tính thời gian thuê trung bình từ bảng rental 

twt_avg_rental_time
as
(
select customer_id, 
	avg(return_date-rental_date) as rental_time 
	from rental 
	group by customer_id
)

--đi đến câu lệnh chính với thông tin cần trả là customer id, tên kh
select a.customer_id, a.first_name,
from custmer as a

--nối bảng tạm với câu lệnh chính để lấy thông tin tổng số hóa đơn và tổng tiên
with twt_total_payment as 
(select customer_id,
count(payment_id) as so_luong,
sum(amount) as so_tien
from payment
group by customer_id),
twt_avg_rental_time
as
(
select customer_id, 
	avg(return_date-rental_date) as rental_time 
	from rental 
	group by customer_id
)
select a.customer_id, a.first_name,
b.so_luong, b.so_tien,
c.rental_time
from customer as a
join twt_total_payment as b on a.customer_id=b.customer_id
join twt_avg_rental_time as c on c.customer_id=b.customer_id
where b.so_luong >30

/*
Tìm những hóa đơn có số tiền cao hơn số tiền trung bình của khách hàng 
đó chi tiêu trên mỗi hóa đơn, kết quả trả ra gồm các thông tin: mã KH,
tên KH, số lượng hóa đơn, số tiền, số tiền trung bình của KH đó

-> mã KH, tên KH có sẵn ở bảng customer
-> số tiền có sẵn ở bảng payment
-> số lượng hóa đơn, số tiền trung bình phải tính
-> có thể tạo 2 CTE. 
1 bảng CTE để tìm số lượng hóa đơn, một bảng để tìm số tiền trung bình
-> tiếp theo viết câu  lệnh để truy vấn các thông tin cần thiết:mã KH,
tên KH, số lượng hóa đơn, số tiền, số tiền trung bình của KH đó
-> sau đó mới bắt đầu áp dụng điều kiện: những hóa đơn 
có số tiền cao hơn số tiền trung bình của khách hàng
*/

with payment_id as
(
select payment_id, customer_id, amount,
(select count(payment_id) from payment as c 
 where c.customer_id =a.customer_id
 group by customer_id
) as count_payment,
(
select avg(amount)
from payment as b
where a.customer_id = b.customer_id
group by customer_id
) as avg_amount
from payment as a
where amount > (select avg(amount)
from payment as b
where a.customer_id = b.customer_id
group by customer_id)   
order by customer_id
)
select d.customer_id, d.first_name, e.count_payment,e.amount, e.avg_amount
from customer as d
join payment_id as e on d.customer_id=e.customer_id



--hoặc
with twt_so_luong as
(
select customer_id, count(payment_id) as so_luong
from payment group by customer_id
),
twt_avg_amount as
(
select customer_id, avg(amount) as avg_amount
from payment group by customer_id
)
select a.customer_id, a.first_name, b.so_luong, c.amount,d.avg_amount
from customer as a
join twt_so_luong as b on a.customer_id=b.customer_id
join payment as c on c.customer_id=a.customer_id
join twt_avg_amount as d on d.customer_id=a.customer_id
where c.amount > d.avg_amount
























