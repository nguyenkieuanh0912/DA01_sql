--- I. DDL: CREATE-DROP-ALTER 
-- dùng để tạo và quản lý các đối tượng trong database
--1. CREATE: tạo bảng vật lý mới
CREATE TABLE manager
(
	manager_id INT PRIMARY KEY,-- PRIMARY KEY để xác định khóa chính,k được trùng nhau và bị null 
	user_name VARCHAR(20) UNIQUE,-- varchar(20) để giới hạn số lượng ký tự--UNIQUE có thể null nhưng k được trùng
	first_name VARCHAR(50),
	last_name VARCHAR(50) DEFAULT 'no info', --DEFAULT: nếu không có thông tin thì sẽ mặc định là một giá trị nào đấy 
	date_of_birth DATE,
	address_id INT
);
--> đầu tiên tạo bảng, rồi xóa, rồi tạo bảng mới với configure và tight/ ràng buộc mới 

--2. DROP: xóa bảng cũ
DROP TABLE manager; 

--3. Ví dụ: Sau khi truy vấn dữ liệu lấy ra danh sách khách hàng và địa chỉ 
-- tương ứng, sau đó lưu thông đó vào bảng vật lý trong data base tên customer_info
-- thông tin cho ra là customer_id, full_name, email, address
CREATE TABLE customer_info AS --tạo bảng customer_info lưu thông tin câu truy vấn này 
(
select a.customer_id, a.first_name || a.last_name as full_name, a.email,
b.address
from customer a
join address b on a.address_id=b. address_id
);

select * from customer_info; 
--> dù trong tương lai bảng customer được cập nhập thêm số liệu, thì bảng
customer_info không thay đổi. Vì tại thời điểm bảng customer_info ở tại thời điểm
bảng đó chưa được cập nhập. 

--4. CREATE TEMPORARY TABLE 

Tạo bảng vật lý gây tốn tài nguyên, bộ nhớ. Với những bảng không sử dụng
thường xuyên, mà chỉ sử dụng trong phiên làm việc lúc đấy, thì không nên 
lưu vào bảng vật lý. Nên tạo bảng tạm, temporary table. Bảng temp table 
chỉ tồn tại ở một phiên làm việc. Khi tắt tab/ phiên làm việc thì bảng sẽ
bị xóa. 

CREATE TEMP TABLE Tmp_customer_info AS (
select a.customer_id, a.first_name || a.last_name as full_name, a.email,
b.address
from customer a
join address b on a.address_id=b. address_id
);

select * from tmp_customer_info;

--> muốn chia sẻ bảng tạm này với nhiều user khác
CREATE GLOBAL TEMP TABLE global_tmp_customer_info AS (
select a.customer_id, a.first_name || a.last_name as full_name, a.email,
b.address
from customer a
join address b on a.address_id=b. address_id
);

---- so sánh vs câu lệnh CTE
WITH Cte_customer_info AS (
select a.customer_id, a.first_name || a.last_name as full_name, a.email,
b.address
from customer a
join address b on a.address_id=b. address_id
)
select * from tmp_customer_info
-> muốn chạy bảng này cần copy cả mục cte dài, thay vì truy vấn như 1 bảng 
bình thường

--5.CREATE VIEW: tạo bảng có thông tin được cập nhật khi bảng customer,
bảng address thay đổi thông tin 

CREATE VIEW vw_customer_info AS  
(
select a.customer_id, a.first_name || a.last_name as full_name, a.email,
b.address
from customer a
join address b on a.address_id=b. address_id
);

select * from vw_customer_info;

--> cập nhật thêm một trường dữ liệu/cột vào view đã có

CREATE OR REPLACE VIEW vw_customer_info AS  
(
select a.customer_id, a.first_name || a.last_name as full_name, a.email,
b.address,
a.active
from customer a
join address b on a.address_id=b.address_id
);

--xóa view
DROP VIEW vw_customer_info;

/*
Challenge 1: Tạo View có tên movies_category hiển thị danh sách các film
gồm title, length, category_name được sắp xếp giảm dần theo length 
Lọc kết quả để chỉ những phim trong danh mục 'Action' và 'Comedy'
*/

CREATE OR REPLACE VIEW movies_category AS
(
select a.title, a.length, c.name as category_name 
from film a
join film_category b on a.film_id=b.film_id
join category c on b.category_id=c.category_id

);
select * from movies_category
where category_name IN ('Action','Comedy') 
order by length desc

--6. ALTER TABLE: Thay đổi cấu trúc của đối tượng trong database, cụ thể
là đối tượng bảng

--a. ADD, DELETE columns
-> để xóa trường thông tin first_name trong bảng manager
ALTER TABLE manager -- thay đổi cấu trúc bảng manager
DROP first_name; --xóa đi cột first_name

ALTER TABLE manager -- thêm một trường thông tin/cột mới vào bảng manager
ADD column first_name VARCHAR(50); --thêm cột first_name với kiểu dữ liệu là varchar, giới hạn 50 chữ cái 

SELECT * FROM manager
--b. RENAME columns: Thay đổi thông tin cột
ALTER TABLE manager-- thay đổi cấu trúc bảng manager 
RENAME column first_name to ten_quan_ly --đổi tên cột first_name thành ten_quan_ly

SELECT * FROM manager
--c. ALTER data types
ALTER TABLE manager -- Thay đổi cấu trúc bảng manager 
ALTER column ten_quan_ly TYPE text  -- cụ thể là thay đổi kiểu dữ liệu sang text  

SELECT * FROM manager


-- II. DML: INSERT, UPDATE, DELETE, TRUNCATE
--1. INSERT-chèn thêm dòng dữ liệu mới 
nextval('city_city_id_seq'::regclass)-- nếu như k có thông tin thì mặc định lấy giá trị tiếp theo. Ví dụ bảng hiện tại đang dừng lại ở city_id
là 200, nếu không có thông tin vào thì nó sẽ mặc định là 201
now(): -- nếu cột last_update không có thông tin thì sẽ mặc định là giờ hiện tại

--để thêm một hoặc nhiều trường dữ liệu 

INSERT INTO city-- chèn thêm vào bảng này ở các trường thông tin 
VALUES (1000, 'A', 44, '2020-01-01 16:10:20');-- giá trị thêm vào 

--check lại xem bảng đã được update giá trị city_id là 1000 chưa?

select * from city 
where city_id=1000;

--thêm nhiều dòng dữ liệu vào bảng 

INSERT INTO city 
VALUES (1000, 'A', 44, '2020-01-01 16:10:20'),
(1001, 'B', 33,'2020-02-01 16:10:20');


select * from city 
where city_id=1001;

--cú pháp 
INSERT INTO table_name
VALUES (...),
(...),
(...)

--Nếu chỉ muốn thêm 1 vài trường dữ liệu

INSERT INTO city (city, country_id)
VALUES ('C',44)

---Kiểm tra kết quả
select * from city 
where city='C'
--> kết quả mặc định trả ra cho city_id là số liền kề là 601. Trong khi bảng gốc
kết thúc ở 200 và ta vừa thêm 1000 vào bảng. Bảng đã thực hiện cộng gía trị 
200 và 1000 rồi chia trung bình ra 600. Giá trị trả cho city_id là giá trị 
tiếp theo sau 600, tức 601. 

--> bảng trả kết quả last_update mặc định là thời gian hiện tại. 


--2. UPDATE: Thay đổi/sửa dữ liệu ở một dòng trong bảng . 
UPDATE city --thay đổi bảng city
SET country_id =100 -- set up trường country_id mà chúng ta muốn thay đổi thông tin sang giá trị mới là 101
WHERE city_id =3; -- tại dòng dữ liệu có city_id là 3

select * from city where city_id=3;

/*
Challenge 2: Viết một câu truy vấn trả về tên khách hàng, quốc gia và
số lượng thanh toán mà họ có: full_name, country, so_luong

Sau đó tạo bảng xếp hạng những khách hàng có doanh thu cao nhất cho mỗi quốc gia
Lọc kết quả chỉ 3 khách hàng đầu của mỗi quốc gia
*/
CREATE TEMP TABLE tmp AS
(
select a.first_name || ' ' || a.last_name as full_name,
d.country, count(e.payment_id) as so_luong, sum(e.amount) as doanh_thu
from customer as a 
join address as b on a.address_id= b.address_id
join city as c on c.city_id=b.city_id
join country as d on c.country_id=d.country_id
join payment as e on e.customer_id=a.customer_id
group by a.first_name || ' ' || a.last_name,d.country
);

select full_name, country, so_luong from tmp;

with cte as
(
select country,full_name, rank() over (partition by country order by doanh_thu desc) as thu_tu
from tmp
)
select * 
from cte
where thu_tu <=3 ;


/*
1. Update giá cho thuê phim 0.99 thành 1.99
2. Điều chỉnh bảng customer như sau :
thêm cột initials (data type varchar(10))
update dữ liệu 	vào cột initials ví dụ Frank Smith thành F.S
*/

-- yêu cầu 1
UPDATE film 
SET rental_rate =1.99
WHERE rental_rate =0.99';

SELECT * FROM film where rental_rate =0.99;

--yêu cầu 2

ALTER TABLE customer
ADD COLUMN initials VARCHAR(10);

SELECT * FROM customer;

UPDATE customer
SET initials = left(first_name,1)|| '.' ||left(last_name,1);

---3.DELETE & TRUNCATE: để xóa 1 hoặc tất cả dòng dữ liệu trong bảng 

--B1: thêm dữ liệu vào bảng manager

INSERT INTO manager
VALUES (1, 'HAPT', 'Tran', '1997-01-01', 20, 'Ha'),
(2, 'NGANDP','Doan', '1987-01-01', 12, 'Ngan'),
(3, 'DUNGHT', 'Hoang', '1991-02-10', 19, 'Thao');

select * from manager

--B2: Xóa dòng có manager_id là 2
DELETE FROM manager -- xóa từ bảng nào
-> Xóa tất cả dòng thông tin của bảng manager. Thời gian thực hiện lâu vì nó sẽ quét toàn bộ bảng và xóa dần từng dòng 

DELETE FROM manager
WHERE manager_id=1 -- Xóa theo điều kiện 

--B3: Muốn xóa nhanh tất cả dòng dữ liệu ngay lập tức
TRUNCATE TABLE manager
select * from manager







