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
       ,floor(sum(sales.quantity * prod.price)) as income
from sales
inner join employees empl on sales.sales_person_id = empl.employee_id 
inner join products prod on sales.product_id = prod.product_id 
group by seller
order by income desc
limit 10


--5.2 Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. Таблица отсортирована по выручке по возрастанию.
with tab as (
   select concat (empl.first_name, ' ', empl.last_name) as seller
          ,floor(avg(sales.quantity * prod.price)) avg_sales
          ,sum(sales.quantity * prod.price) as income
    from sales
    inner join employees empl on sales.sales_person_id = empl.employee_id 
    inner join products prod on sales.product_id = prod.product_id 
    group by seller
    order by avg_sales)

select seller, avg_sales as average_income
from tab
where avg_sales < (select floor(avg(sales.quantity * prod.price))
                        from sales
                        inner join employees empl on sales.sales_person_id = empl.employee_id 
                        inner join products prod on sales.product_id = prod.product_id)
order by average_income asc;



--5.3 Третий отчет содержит информацию о выручке по дням недели.
--Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку.
--Отсортируйте данные по порядковому номеру дня недели и seller
select concat (empl.first_name, ' ', empl.last_name) as seller
       ,trim(to_char (sales.sale_date, 'day')) as day_of_week 
       ,floor(sum(sales.quantity * prod.price)) as income
from sales
inner join employees empl on sales.sales_person_id = empl.employee_id 
inner join products prod on sales.product_id = prod.product_id
group by seller, day_of_week, extract (isodow from sales.sale_date)
order by extract (isodow from sales.sale_date), seller;


--6.1 Запрос на количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. Итоговая таблица должна быть отсортирована по возрастным группам.
with tab as (select *,
case when age between 16 and 25 then '16-25'
     when age between 26 and 40 then '26-40'
     when age >40 then '40+'
end as age_category
from customers)

select age_category, count(age_category) as age_count
from tab
group by age_category
order by age_category


--6.2 Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке, которую они принесли.
--Сгруппируйте данные по дате, которая представлена в числовом виде ГОД-МЕСЯЦ. 
select selling_month, count(distinct customer_id) as total_customers,floor(sum(income)) as income
from (select sales.*,
      to_char(date_trunc('month', sales.sale_date), 'yyyy-mm') as selling_month,
     (sales.quantity*prod.price) as income
      from sales
      inner join products prod on sales.product_id = prod.product_id)
group by selling_month
order by selling_month asc



--6.3 Третий отчет следует составить о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0).
--Итоговая таблица должна быть отсортирована по id покупателя.
with tab as(     
            select sales.*,
            to_char(date_trunc('month', sales.sale_date), 'yyyy-mm') as selling_month,
            min(sale_date) over (partition by sales.customer_id) as minsaledate,
            sales.quantity* prod.price as income,
            concat(cust.first_name, ' ', cust.last_name) as custname,
            concat(empl.first_name, ' ', empl.last_name) as salespname
            from sales
            inner join products prod on sales.product_id = prod.product_id
            inner join customers cust on sales.customer_id = cust.customer_id
            inner join employees empl on sales.sales_person_id = empl.employee_id) 

select custname as customer, sale_date, salespname as seller
from tab
where sale_date = minsaledate
and income = 0 
group by custname, sale_date, salespname, customer_id
order by customer_id asc

