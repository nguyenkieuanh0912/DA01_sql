SELECT *
FROM SALES_DATASET_RFM_PRJ;

--- 1.CHUYỂN ĐỔI KIỂU DỮ LIỆU 
alter table SALES_DATASET_RFM_PRJ
alter column ordernumber type numeric using (trim(ordernumber)::numeric)

ALTER TABLE SALES_DATASET_RFM_PRJ
alter column priceeach type numeric USING (priceeach::numeric)

ALTER TABLE SALES_DATASET_RFM_PRJ
alter column 
quantityordered type numeric USING (quantityordered::numeric)


ALTER TABLE SALES_DATASET_RFM_PRJ
alter column
orderlinenumber type numeric USING (orderlinenumber::numeric)

ALTER TABLE SALES_DATASET_RFM_PRJ
alter column
sales type numeric USING (sales::numeric)


ALTER TABLE SALES_DATASET_RFM_PRJ
alter column orderdate type timestamp USING orderdate::timestamp without time zone




/*
2.Check NULL/BLANK (‘’)  ở các trường: ORDERNUMBER, QUANTITYORDERED,
PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE.
*/
select 
ordernumber, quantityordered, priceeach,
orderlinenumber, sales, orderdate
from SALES_DATASET_RFM_PRJ
where
ordernumber is null 
or quantityordered is null or priceeach is null or
orderlinenumber is null or sales is null or orderdate is null


/*
3. Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME . 
Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ cái đầu tiên 
viết hoa, chữ cái tiếp theo viết thường. 
Gợi ý: ( ADD column sau đó INSERT)
*/
--cột contactlastname trước 
alter table SALES_DATASET_RFM_PRJ
add column contactlastname text;


update SALES_DATASET_RFM_PRJ 
set contactlastname = upper(left(contactfullname,1))||
			lower(substring(contactfullname from 2 for position('-' in contactfullname)-2)) 

SELECT *
FROM SALES_DATASET_RFM_PRJ;

--cột contactfirstname sau
alter table SALES_DATASET_RFM_PRJ
add column contactfirstname text;

update SALES_DATASET_RFM_PRJ 
set contactfirstname = upper(substring(contactfullname from position('-' in contactfullname)+1 for 1 ))||
lower(right(contactfullname, length(contactfullname)- position('-' in contactfullname)-1))

SELECT *
FROM SALES_DATASET_RFM_PRJ;

/*
4.Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra 
từ ORDERDATE
*/

alter table SALES_DATASET_RFM_PRJ
add column QTR_ID int,
add MONTH_ID int,
add YEAR_ID int;


update SALES_DATASET_RFM_PRJ 
set qtr_id= 
case 
when extract(month from orderdate) in (1,2,3) then 1 
when extract(month from orderdate) in (4,5,6) then 2 
when extract(month from orderdate) in (7,8,9) then 3 
when extract(month from orderdate) in (10,11,12) then 4  
end,
month_id= extract(month from orderdate),
year_id = extract(year from orderdate);


SELECT orderdate, qtr_id, month_id, year_id
FROM SALES_DATASET_RFM_PRJ;

/*
5.Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED và hãy chọn 
cách xử lý cho bản ghi đó (2 cách) 
*/
---- Tìm outlier
--Cách 1:Sử dụng boxplot 
with twt as
(
SELECT
Q1-1.5*IQR AS min_value, 
Q3+1.5*IQR AS max_value
FROM (
select 
percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered) as Q1,
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered) as Q3,
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered) - percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered) AS IQR
from SALES_DATASET_RFM_PRJ) as a)
select quantityordered
from SALES_DATASET_RFM_PRJ
where quantityordered is not null and (quantityordered < (select min_value from twt) or
quantityordered > (select max_value from twt)) ;

--Cách 2: Sử dụng Z-value
with cte as (
select quantityordered,
(select avg(quantityordered) from SALES_DATASET_RFM_PRJ) as avg_quantity,
(select stddev(quantityordered) from SALES_DATASET_RFM_PRJ) as sttdev
from SALES_DATASET_RFM_PRJ)
select 
quantityordered, (quantityordered-avg_quantity)/sttdev as Z_score
from cte
where abs((quantityordered-avg_quantity)/sttdev) >3 

----Xử lý outlier
--Cách 1:Xóa giá trị đó khỏi bảng
with twt as
(
SELECT
Q1-1.5*IQR AS min_value, 
Q3+1.5*IQR AS max_value
FROM (
select 
percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered) as Q1,
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered) as Q3,
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered) - percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered) AS IQR
from SALES_DATASET_RFM_PRJ) as a),
twt_outlier as
(
select quantityordered
from SALES_DATASET_RFM_PRJ
where quantityordered is not null and (quantityordered < (select min_value from twt) or
quantityordered > (select max_value from twt))
)
delete from SALES_DATASET_RFM_PRJ
where quantityordered in (select quantityordered from twt_outlier)

--Cách 2: Thay thế giá trị ngoại lai bằng giá trị mới, phổ biến là thay thế bằng giá trị trung bình

with cte as 
(
select quantityordered,
(select avg(quantityordered) from SALES_DATASET_RFM_PRJ) as avg_quantity,
(select stddev(quantityordered) from SALES_DATASET_RFM_PRJ) as sttdev
from SALES_DATASET_RFM_PRJ
),
twt_outlier as 
(
select 
quantityordered, (quantityordered-avg_quantity)/sttdev as Z_score
from cte
where abs((quantityordered-avg_quantity)/sttdev) >3
)
update SALES_DATASET_RFM_PRJ
set quantityordered = (select avg(quantityordered) from SALES_DATASET_RFM_PRJ)
where quantityordered in (select quantityordered from twt_outlier);



/*
6.Sau khi làm sạch dữ liệu, hãy lưu vào bảng mới tên là 
SALES_DATASET_RFM_PRJ_CLEAN
*/
create table SALES_DATASET_RFM_PRJ_CLEAN as
(
select * from SALES_DATASET_RFM_PRJ
)









