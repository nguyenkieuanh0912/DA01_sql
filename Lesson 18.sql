select *
from user_data
order by users desc ;
---IV. Tìm và xử lý outlier 
---Cách 1. sử dụng IQR/ BOXPLOT để tìm ra outlier
--B1: Tính Q1, Q3, IQR
--B2: xác định min=Q1-1.5*IQR, MAX= Q3+1.5*IQR
--B3: xác định outlier <min or > max
with twt as
(
SELECT
Q1-1.5*IQR AS min_value, 
Q3+1.5*IQR AS max_value
FROM (
select 
percentile_cont(0.25) WITHIN GROUP (ORDER BY users) as Q1,
percentile_cont(0.75) WITHIN GROUP (ORDER BY users) as Q3,
percentile_cont(0.75) WITHIN GROUP (ORDER BY users) - percentile_cont(0.25) WITHIN GROUP (ORDER BY users) AS IQR
from user_data) as a)
--B3: xác định outlier <min or > max
select *, (select min_value from twt), (select max_value from twt)
from user_data;
--> tùy vào bài toán thực tế, chưa thể xác định số lượng đột biến do sự kiến nào, hay do nhập nhầm hoặc đồng bộ dữ liệu có vấn đề

---Cách 2. Sử dụng Z-score 
--B1: Tính Z-score =(user- avg_user)/standard_deviation 
select avg(users), 
stddev(users)
from user_data;

with cte as (
select data_date, users, 
(select avg(users) from user_data) as avg_user,
(select stddev(users) from user_data) as sttdev
from user_data),
twt_outlier as
(
select 
data_date, users, (users-avg_user)/sttdev as Z_score
from cte
where abs((users-avg_user)/sttdev) >3 --tìm trị tuyệt đối lớn hơn 3 
)
/*
Lựa chọn phương pháp xử lý giá trị ngoại lai tùy vào tình huống hiện tại
Thường có 2 cách xử lý giá trị ngoại lai
- 1. Xóa giá trị đó khỏi bảng
- 2. Thay thế giá trị ngoại lai bằng giá trị mới, phổ biến là thay thế bằng 
giá trị trung bình
*/
update user_data
set users = (select avg(users) from user_data)
where users in (select users from twt_outlier);
--- hoặc xóa
delete from user_data
where users in (select users from twt_outlier)

---V. Clean data checklist
-- 1. Xử lý dữ liệu bị trùng lặp

VD: tìm address bị trùng lặp, loại bản ghi cũ hơn. 

với cách sử dụng (select distinct address from address), để loại bản ghi lặp
Bảng hàng triệu bản ghi sẽ mất thời gian, vì nó sẽ quét từ trên xuống dưới và chọn ra
giá trị trùng lặp để loại. Nó sẽ lâu và hiệu quả kém. Nên hạn chế sử dụng
distinct để loại giá trị trùng lặp. Bên cạnh đó distinct không giúp tìm giá trị
trùng lặp 

Cách để tìm giá trị trùng lặp với row_number

select * 
from (
select 
row_number () over (partition by address order by last_update desc ) as stt,
*
from address ) as a
where stt>1;
---> cho ra kết quả 1074 Binzhow Manor

select * from address
where address = '1074 Binzhow Manor'
---> để tìm ra bản ghi bị lặp

---hoặc là chỉ lấy kết quả có stt=1, tức là nó không bị lặp
select * 
from (
select 
row_number () over (partition by address order by last_update desc ) as stt,
*
from address ) as a
where stt=1







 