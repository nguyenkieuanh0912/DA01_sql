-- INNER JOIN 
-- Cú pháp 
SELECT
t1.*, t2.*
FROM table1 AS t1
INNER JOIN table2 AS t2
ON t1.key1=t2.key2

select a.payment_id, a.customer_id, 
b.first_name, b.last_name
from payment as a
inner join customer as b
on a.customer_id=b.customer_id

--Có bao nhiêu người chọn ghế ngồi theo các loại sau
business
comfort
economy 

fare_conditions: 1st column
count: 2nd column

select seats.fare_conditions, count(*)
from boarding_passes
inner join seats
on boarding_passes.seat_no= seats.seat_no
group by seats.fare_conditions

--LEFT JOIN -RIGHT JOIN
SELECT
t1.*, t2.*
FROM table1 AS t1 -- Bảng gốc
LEFT JOIN table2 AS t2 -- Bảng tham chiếu
ON t1.key1=t2.key2;

SELECT
t1.*, t2.*
FROM table1 AS t1 -- Bảng tham chiếu
RIGHT JOIN table2 AS t2 -- Bảng gốc
ON t1.key1=t2.key2;

--Tìm thông tin các chuyến bay của từng máy bay
--B1: xác định bảng: máy bay: aircrafts_data
chuyến bay: flights
--B2: xác định key join: aircraft_code
--B3: chọn phương thức JOIN: phải hiển thị tất cả thông tin máy bay nên chọn left join

select t1.aircraft_code, t2.flight_no
from aircrafts_data as t1
left join flights as t2
on t1.aircraft_code=t2.aircraft_code
where t2.flight_no is null

/*Tìm hiểu ghế nào được đặt thường xuyên nhất. đảm bảo tất
cả các ghế đều được liệt kê ngay cả khi chúng chưa bao giờ 
được đặt 
Có chỗ ngồi nào chưa bh được đặt ko
Chỉ ra hàng ghế nào được đặt thường xuyên nhất*/
select a.seat_no, count( b.ticket_no)
from seats as a
left join boarding_passes as b
on a.seat_no= b.seat_no
group by a.seat_no
order by count( b.ticket_no) desc;

select a.seat_no
from seats as a
left join boarding_passes as b
on a.seat_no= b.seat_no
where b.seat_no is null;

select right(a.seat_no,1), count(distinct b.ticket_no)
from seats as a
left join boarding_passes as b
on a.seat_no= b.seat_no
group by right(a.seat_no,1)
order by count(distinct b.ticket_no) desc;

--FULL JOIN
SELECT
t1.*, t2.*
FROM table1 AS t1 
FULL JOIN table2 AS t2 
ON t1.key1=t2.key2;

SELECT count(*) FROM bookings.boarding_passes as a
FULL JOIN bookings.tickets as b
ON a.ticket_no= b.ticket_no
where a.ticket_no is null

--JOIN on multiple conditions
SELECT
t1.*, t2.*
FROM table1 AS t1 
FULL JOIN table2 AS t2 
ON t1.key1=t2.key1
AND t1.key2=t2.key2
/* Tính giá trung bình của từng số ghế máy bay
B1: xác định input, output
output: số ghế, giá trung bình của ghế
input: bảng seats, ticket_flights , giá từ bảng ticket_flights
*/
select * from bookings.seats
select * from bookings.ticket_flights
select * from bookings.boarding_passes
--PK: primary key, bảng ticket_flights cần 2 primary key do một vé máy bay có thể đi nhiều chuyến máy bay để transit

select 
a.seat_no,
avg(b.amount) as avg_amount
from bookings.boarding_passes as a
left join bookings.ticket_flights as b
on a.ticket_no=b.ticket_no
and a.flight_id=b.flight_id
group by a.seat_no
order by avg(b.amount) desc
 
--liệt kê số vé, tên kh, giá vé, giờ bay, giờ kết thúc
số vé, tên kh: tickets
giá vé: ticket_flights
giờ bay, giờ kết thúc: flights 

select a.ticket_no, a.passenger_name,b.amount, 
c.scheduled_departure,c.scheduled_arrival
from tickets as a
inner join ticket_flights as b on a.ticket_no=b.ticket_no
inner join flights as c on b.flight_id=c.flight_id

--bảng flights có flight_id làm khóa chính nên chỉ cần join 1 điều kiện 


/*Công ty muốn tùy chỉnh chiến dịch của họ cho phù hợp với 
khách hàng tùy thuộc vào đất nước họ đến. Những khách hàng
nào đến từ Brazil?
Viêt truy vấn để lấy first_name, last_name, email và quốc 
gia từ tất cả khách hàng đến từ Brazil*/

select a.first_name, a.last_name,
a.email, d.country
from public.customer as a
join public.address as b on a.address_id=b.address_id-- inner join và join đều như nhau
join public.city as c on b.city_id = c.city_id
join public.country as d on c.country_id = d.country_id
where d.country ='Brazil'
--sử dụng bảng b và c như bảng trung gian để kết nối bảng a và d

----SELF-JOIN

CREATE TABLE employee (
	employee_id INT,
	name VARCHAR (50),
	manager_id INT
);

INSERT INTO employee 
VALUES
	(1, 'Liam Smith', NULL),
	(2, 'Oliver Brown', 1),
	(3, 'Elijah Jones', 1),
	(4, 'William Miller', 1),
	(5, 'James Davis', 2),
	(6, 'Olivia Hernandez', 2),
	(7, 'Emma Lopez', 2),
	(8, 'Sophia Andersen', 2),
	(9, 'Mia Lee', 3),
	(10, 'Ava Robinson', 3);
	
	
SELECT emp.employee_id, emp.name, emp.manager_id, mng.name as mng_name
FROM employee AS emp
LEFT JOIN employee AS mng
ON emp.manager_id =mng.employee_id

/*Tìm những bộ phim có cùng thời lượng phim 
với output: ttitle1, title2, length */
select a.title as title1, b.title as title2, a.length 
from film as a
join film as b
on a.length=b.length
where a.title <> b.title

--UNION
NOTE: 
1. Số lượng cột ở 2 bảng phải giống nhau
2. Kiểu dữ liệu trong cùng 1 cột phải giống nhau
3. UNION loại dữ liệu trùng lặp còn UNION ALL thì không


SELECT col1, col2, col3, ...coln
FROM table1
UNION/UNION ALL 
SELECT col1, col2, col3, ...coln
FROM table2
UNION/UNION ALL 
SELECT col1, col2, col3, ...coln
FROM table3;

SELECT first_name FROM actor
UNION
SELECT first_name FROM customer
ORDER BY first_name;

SELECT first_name, 'actor' AS source FROM actor--ghi nguồn nếu first_name lấy từ bảng actor
UNION ALL
SELECT first_name, 'customer' AS souce FROM customer
ORDER BY first_name;

SELECT first_name, 'actor' AS source FROM actor--ghi nguồn nếu first_name lấy từ bảng actor
UNION 
SELECT first_name, 'customer' AS souce FROM customer
UNION 
SELECT first_name, 'staff' AS souce FROM staff
ORDER BY first_name;
