---LOWER, UPPER, LENGTH
SELECT
email,
lower(email) as lower_email,
upper(email) as upper_email,
length(email) as length_email
FROM customer
where length(email) >30

/*liệt kê khách hàng có họ hoặc tên nhiều hơn 10 ký tự
trả kết quả dạng chữ thường */
select lower(first_name), 
lower(last_name)
from customer
where length(first_name) >10 or length(last_name) >10

--LEFT(), RIGHT()
SELECT
first_name,
LEFT(first_name,3),
right(first_name,2),
right(LEFT(first_name,3),2)
FROM customer

/* trước tiên trích xuất 5 ký tự cuối cùng của địa chỉ email 
địa chỉ email luôn kết thúc bằng org
trích xuất dấu . từ địa chỉ email*/
select right(email,5),
left(right(email,4),1)
from customer

--nối chuỗi CONCATENATE
select
first_name,
last_name,
first_name || ' ' || last_name as full_name, -- || dùng để nối chuỗi
CONCAT(first_name, ' ', last_name) as full_name
from customer

/*mask địa chỉ email mar***h@sakilacustomer.org*/
select left(email,3)||'***'||right(email,20) as email
from customer


--REPLACE: thay thế kí tự
select
email, 
REPLACE (email, '.org','.com' ) as new_email
from customer

--POSITION: tìm vị trí của một ký tự đặc biệt
select 
email,
left(email, position ('@' IN email)-1)
from customer

--lấy ra 2 ký tự từ 2-4 của trường first name
select first_name,
right(left(first_name,4),3),
SUBSTRING(first_name FROM 2 FOR 3)
from customer

-- lấy ra thông tin họ của khách hàng từ email
select email,
position('.' in email),
position('@' in email),
position('@' in email) -position('.' in email) -1,
substring(email from position('.' in email)+1 for position('@' in email)-position('.' in email) -1)
from customer

/*Giả sử bạn chỉ có địa chỉ email và họ của khách hàng 
trích xuất tên từ địa chỉ email và nối nó với họ
Kết quả ở dạng Họ, Tên */
select 
substring(email from 1 for position('.' in email)-1)|| ', ' ||last_name
from customer

--EXTRACT
select 
rental_date,
extract (month from rental_date),
extract (year from rental_date),
extract (hour from rental_date)
from rental

-- năm 2020 có bao nhiêu đơn hàng cho thuê trong mỗi tháng
select 
extract(month from rental_date) as month_in_2020,
count(*) as rental_number
from rental
where extract(year from rental_date) ='2020' 
group by extract(month from rental_date)

/* phân tích các khoản thanh toán 
- tháng nào có tổng số tiền cao nhất
- ngày nào trong tuần có tổng số tiền cao nhất
với 0 là chủ nhật
- số tiền cao nhất mà một khách đã chi tiêu trong tuần
là bao nhiêu?*/
select extract (month from payment_date) as month,
sum(amount)
from payment
group by extract (month from payment_date)
order by sum(amount) desc
limit 1

select extract (DOW from payment_date) as day_of_week,
sum(amount)
from payment
group by extract (DOW from payment_date)
order by sum(amount) desc
limit 1

select customer_id,
extract(week from payment_date),
sum(amount)
from payment
group by customer_id, extract(week from payment_date)
order by sum(amount) desc
limit 1


--To_char
select
payment_date,
extract(year from payment_date),
to_char(payment_date,'dd-mm-yyyy hh:mm:ss'),
to_char(payment_date,'dd-mm'),
to_char(payment_date,'Month'),
to_char(payment_date,'MONTH'),
to_char(payment_date,'yyyy')
from payment

-- INTERVAL
select current_date,
current_timestamp,
rental_date,
return_date,
customer_id,
extract(day from return_date-rental_date)*24 
+ extract(hour from return_date-rental_date) || ' giờ'
from rental


/* tạo danh sách tất cả thời gian đã thuê của khách hàng
với customer_id 35
Ngoài ra bạn cần tìm hiểu khách nào có thời gian thuê
trung bình dài nhất */

select customer_id, rental_date, 
return_date,
return_date-rental_date
from rental
where customer_id = '35';

select customer_id,
avg(return_date-rental_date)
from rental
group by customer_id
order by avg(return_date-rental_date) desc