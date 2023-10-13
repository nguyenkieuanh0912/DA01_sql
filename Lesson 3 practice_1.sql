--EX1
SELECT NAME FROM CITY WHERE COUNTRYCODE = 'USA' AND POPULATION > 120000;

--EX2
SELECT * FROM CITY WHERE COUNTRYCODE ='JPN'; 

--ex3: 
SELECT CITY, STATE FROM STATION;

--ex4: 
SELECT DISTINCT CITY FROM STATION WHERE CITY LIKE 'A%' OR CITY LIKE  'E%' OR CITY LIKE 'I%' OR CITY LIKE 'O%' OR CITY LIKE 'U%' ;

--ex5:
SELECT DISTINCT CITY FROM STATION WHERE CITY LIKE '%a' OR CITY LIKE  '%e' OR CITY LIKE '%i' OR CITY LIKE '%o' OR CITY LIKE '%u';

--ex6: 
SELECT DISTINCT CITY FROM STATION WHERE CITY NOT LIKE 'A%' AND CITY NOT LIKE 'E%' AND CITY NOT LIKE 'I%' AND CITY NOT LIKE 'O%' AND CITY NOT LIKE 'U%';

--ex7: 
select name from Employee order by name 

--ex8:
select name from Employee where salary >2000 and months <10 order by employee_id

--ex9:
select product_id from Products where low_fats = 'Y' and recyclable ='Y'

--ex10:
select name from Customer where referee_id IS NULL or referee_id = 1;

--ex11:
elect name, population, area from World where area >= 3000000 or population >= 25000000;

--ex12:
select distinct author_id as id from Views where author_id = viewer_id order by id;

--ex13: 
SELECT distinct part, assembly_step FROM parts_assembly 
where finish_date is null and assembly_step is not null;
 
--ex14: 
select * from lyft_drivers
where yearly_salary <= 30000 or yearly_salary >= 70000;

--ex15: 
select distinct advertising_channel from uber_advertising
where year = 2019 and money_spent > 100000;
