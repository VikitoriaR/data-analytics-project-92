-- 1 запрос на товары, которые продавались больше всего и в каком количестве
select productid, sum(quantity) as total_sales
from sales_sample
group by productid
order by total_sales desc

--2 запрос 10 самых продаваемых товаров
select productid as ProductID, sum(quantity) as TotalQuantity
from sales_sample
group by productid
order by TotalQuantity desc
limit 10


--3 запрос 10 товаров, которые продались на наибольшую сумму
select salss.productid as ProductID, floor(sum(salss.quantity * prod.price)) as Amount
from sales_sample salss
inner join products prod on salss.productid = prod.product_id 
group by salss.productid
order by amount desc
limit 10

--4 Считаем общее количество покупателей из таблицы customers.
select count(distinct customer_id) as customers_count
from customers