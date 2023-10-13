---SELECT
SELECT * FROM actor;
SELECT first_name, last_name FROM actor;
SELECT first_name AS "tên khách hàng",
last_name AS "họ khách hàng"
FROM actor;

---List tất cả các khách hàng với thông tin họ, tên, email
SELECT last_name as "họ",first_name as "tên",
email
FROM customer

---ORDER BY
SELECT * FROM payment 
ORDER BY customer_id, amount desc, payment_date desc

---DISTINCT
SELECT DISTINCT first_name, last_name from actor order by first_name
---Sắp xếp giá đơn hàng từ cao xuống thấp
SELECT DISTINCT amount
FROM payment
ORDER BY amount DESC

--- Top 100 hóa đơn có giá trị lớn nhất
SELECT *
FROM payment
ORDER BY amount DESC
LIMIT 100

--- Liệt kê hóa đơn có số tiền là 10,99 đô
SELECT *
FROM payment
WHERE amount =10.99

--- Liệt kê những diễn viên có tên Nick
SELECT *
FROM actor
WHERE first_name ='NICK'

--- Liệt kê những diễn viên thiếu tên
SELECT *
FROM actor
WHERE first_name IS NULL 

--- Danh sách các khoản thanh toán không quá 2 $ bao gồm mã thanh toán và số tiền
SELECT payment_id, amount FROM payment WHERE amount <=2

---Danh sách các khoản thanh toán lớn hơn 4$ và nhỏ hơn 9$
SELECT * FROM payment WHERE amount >4 AND amount <9

---Danh sách các khoản thanh toán
lớn hơn 4$ HOẶC nhỏ hơn 9$
SELECT * FROM payment WHERE
amount >4 OR amount <9

---Danh sách các khoản thanh toán của khách hàng 322,
---346và 354 với số tiền nhỏ hơn 2 hoặc lớn hơn 10
---sắp xếp theo thứ tự tăng dần theo mã khách hàng 
--- và giảm dần theo số tiền
SELECT * FROM payment WHERE
(customer_id = 322 OR customer_id = 346 or customer_id =354)
and (amount <2 or amount >10)
order by customer_id asc, amount desc

--- DANH SÁCH THANH TOÁN >=2 VÀ <= 9
SELECT * FROM payment WHERE amount BETWEEN 2 AND 9

--- hiển thị hóa đơn có số id 16055, 16061, 16065, 16068
SELECT * FROM payment WHERE payment_id IN (16055, 16061, 16065, 16068)


---đã có 6 khiếu nại của khách hàng về các khoản thanh toán 
---customer_id 12, 25, 67, 93, 124, 134
---tìm các khoản thanh toán của những khách này 
---với số tiền 4,99 7,99 và 9,99 trong tháng 1 năm 2020
SELECT * FROM payment 
WHERE customer_id IN (12, 25, 67, 93, 124, 134)
AND amount IN (4.99, 7.99, 9.99)
AND payment_date BETWEEN '2020-01-01' AND '2020-02-01'

--tìm diễn viên có tên bắt đầu bằng chữ N
select * from actor
where first_name LIKE 'N%'-- bắt đầu bằng chữ N

--tìm diễn viên có tên kết thúc bằng chữ N
select * from actor
where first_name LIKE '%N'-- kết thúc bằng chữ N

--tìm tên diễn viên có  chữ N
select * from actor
where first_name LIKE '%N%'

-- chữ thứ hai là N
select * from actor
where first_name LIKE '_N%'

-- tên bắt đầu bằng S hoặc J

select * from actor
where first_name LIKE 'S%' OR first_name LIKE 'J%'

/*danh sách các bộ phim có chứa Saga trong phần mô tả 
và 1qtiêu đề bắt đầu bằng A hoặc kết thúc bằng R*/
select *
from film
where description like '%Saga%'
and (title like 'A%' or title like '%R')

/*danh sách khách hàng có tên chứa chữ ER và chữ cái 
thứ hai là A. sắp xếp theo họ giảm dần*/	
select *
from customer
where first_name like '%ER%' and first_name like '_A%'
order by last_name desc