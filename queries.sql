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


--5.1 Запрос на извлечение данных о продавце, суммарной выручке с проданных товаров и количестве проведенных сделок, и отсортирована по убыванию выручки
select concat (empl.first_name, ' ', empl.last_name) as seller, count(sales.sales_person_id) as operations
       ,sum(sales.quantity * prod.price) as income
from sales
inner join employees empl on sales.sales_person_id = empl.employee_id 
inner join products prod on sales.product_id = prod.product_id 
group by seller
order by income desc
limit 10


--5.2 Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. Таблица отсортирована по выручке по возрастанию.
with tab as (
   select concat (empl.first_name, ' ', empl.last_name) as seller
          ,round(avg(sales.quantity * prod.price)) avg_sales
          ,sum(sales.quantity * prod.price) as income
    from sales
    inner join employees empl on sales.sales_person_id = empl.employee_id 
    inner join products prod on sales.product_id = prod.product_id 
    group by seller
    order by avg_sales)

select seller, avg_sales as average_income
from tab
where avg_sales < (select round(avg(sales.quantity * prod.price))
                        from sales
                        inner join employees empl on sales.sales_person_id = empl.employee_id 
                        inner join products prod on sales.product_id = prod.product_id)
order by average_income asc;



--5.3 Третий отчет содержит информацию о выручке по дням недели.
--Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку.
--Отсортируйте данные по порядковому номеру дня недели и seller
select concat (empl.first_name, ' ', empl.last_name) as seller
       ,trim(to_char (sales.sale_date, 'Day')) as day_of_week 
       ,round(sum(sales.quantity * prod.price)) as total
from sales
inner join employees empl on sales.sales_person_id = empl.employee_id 
inner join products prod on sales.product_id = prod.product_id
group by seller, day_of_week, extract (isodow from sales.sale_date)
order by extract (isodow from sales.sale_date), seller;