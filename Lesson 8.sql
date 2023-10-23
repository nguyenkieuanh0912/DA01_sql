/*tìm hiểu xem công ty đã bán bao nhiêu vé 
trong các danh mục sau:
- low price ticket: total_amount <20,000
- mid price ticket: total_amount between 
20000 and 150000
- high price ticket: total_amount >=150000
*/

select
case
when total_amount <20000 then 'low price'
when total_amount between 20000 and 150000 then ' mid price'
when total_amount > 150000 then 'high price'
end category,
count(*) as number
from bookings
group by category;

:(())
select
case
when amount <20000 then 'low price'
when amount between 20000 and 150000 then ' mid price'
when amount > 150000 then 'high price'
end category,
count(*) as number
from ticket_flights
group by category;

/* Cần biết bao nhiêu chuyến bay đã khởi hành 
vào các mùa
mùa xuân: tháng 2 3 4
mùa hè: tháng  5 6 7
mùa thu: tháng 8 9 10
mùa đông: tháng 11 12 1
*/
select 
case
when extract(month from scheduled_departure) in (2,3,4) then 'spring'
when extract(month from scheduled_departure) in (5,6,7) then 'summer'
when extract(month from scheduled_departure) in (8,9,10) then 'fall'
else 'winter'
end season,
count(*) as flight_number
from flights
group by season

/*tạo danh sách xem phim theo cấp độ
- xếp hạng PG hoặc PG-13 hoặc thời lượng lớn
hơn 210 p 'Great rating or long (tier 1)'
- mô tả chứa 'Drama' và thời lượng hơn 
90 phút 'Long drama (tier 2)'
- mô tả chứa 'Drama' và thời lượng không quá 
90 phút 'Shcity drama (tier 3)'
- giá thuê thấp hơn $1 'Very cheap (tier 4)'

Nếu một bộ phim thuộc nhiều danh mục, nó sẽ được
chỉ định ở cấp cao hơn.
Làm thế nào để chỉ lọc phim xuất hiện ở một trong
những cấp độ này */
select
film_id, 
case
when rating IN ('PG', 'PG-13') or length >210 then 'Great rating or long (tier 1)'
when description like '%Drama%' and length >90 then 'Long drama (tier 2)'
when description like '%Drama%' and length <=90 then 'Shcity drama (tier 3)'
when rental_rate <1 then 'Very cheap (tier 4)'
end as category
from film
where 
case
when rating IN ('PG', 'PG-13') or length >210 then 'Great rating or long (tier 1)'
when description like '%Drama%' and length >90 then 'Long drama (tier 2)'
when description like '%Drama%' and length <=90 then 'Shcity drama (tier 3)'
when rental_rate <1 then 'Very cheap (tier 4)'
end is not null 
order by category;

CASE
	WHEN ... THEN ...
	ELSE
END AS category;

--PIVOT BY CASE-WHEN
/*Tính tổng số tiền khách hàng theo từng loại
hóa đơn high-medium-low của từng khách hàng
high: amount >10
medium: between 5 and 10
low: amount<5 */
select customer_id,
sum(case
	when amount >10 then amount
	else 0
end) as high,
sum(case
	when amount between 5 and 10 then amount
	else 0
end) as medium,
sum(case
	when amount < 5 then amount
	else 0
end) as low
from payment
group by customer_id
order by customer_id

/*Thống kê có bao nhiêu bộ phim được đánh giá 
là R, PG, PG-13 ở các thể loại phim long_
medium short
long: length>120
medium: length between 60 and 120
short: length <60
*/
select 
case
	when length >120 then 'long'
	when length between 60 and 120 then 'medium'
	else 'short'
end as category,
sum
(case 
		when rating ='R' then 1
		else 0
	end) as R,
sum
(case 
		when rating ='PG' then 1
		else 0
	end) as PG,
sum
(case 
		when rating ='PG-13' then 1
		else 0
	end) 
	as PG_13
from film
group by category



--COALESCE update giá trị null với giá trị mới
select 
scheduled_arrival,
actual_arrival,
coalesce(actual_arrival, '2020-01-01'),
/*nếu như bản ghi nào ở trường actual_arrival bị null,
thì thay bằng giá trị 2020-01-01*/
coalesce(actual_arrival, scheduled_arrival),
/*nếu như bản ghi nào ở trường actual_arrival bị null,
thì thay giá trị tương ứng ở trường scheduled_arrival*/
coalesce(actual_arrival- scheduled_arrival,'00-00')
--actual_arrival- scheduled_arrival là interval và '00-00' cũng là interval
from flights

COALESCE(trường_có_null, giá_trị_thay_thế_cho_gtrị_null)
Lưu ý: gía trị thay thế phải có cùng dạng data type với trường có giá trị null

--cast
select 
scheduled_arrival,
actual_arrival,
coalesce(actual_arrival, '2020-01-01'),
coalesce(actual_arrival, scheduled_arrival),
coalesce(cast(actual_arrival- scheduled_arrival as varchar),'not arrived')
--định dạng lại (actual_arrival- scheduled_arrival)
from flights


--Chuyển đổi kiểu dữ liệu với kiểu dữ liệu thường gặp: 
string/number/datetime

--chuyển từ string sang number interger, với string phải chứa chữ số 0,1,2, không được chứa a,b,c
select 
*,
cast(ticket_no as bigint)
from ticket_flights

--chuyển từ number sang string
select 
*,
cast(amount as varchar) 
from ticket_flights

--chuyển từ dạng datetime sang string
select 
*,
cast(scheduled_departure as varchar)
from flights


-- chuyển từ dạng số nguyên sang số thập phân khi chia số nguyên cho số nguyên, để sử dụng hàm round làm tròn cho số thập phân
select
round(cast(sum(item_count*order_occurrences)/sum(order_occurrences) as decimal),1)
from items_per_order	