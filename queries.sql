--начало
-- скрипт считает общее число записей в таблице customers

select count(*) as customers_count

from customers;


-- Подготовьте отчет с продавцами у которых наибольшая выручка

select
	employees.first_name || ' ' || employees.last_name as seller,
	COUNT(sales.sales_id) as operations,
	FLOOR(SUM(products.price * sales.quantity)) as income
from sales
inner join employees on
	sales.sales_person_id = employee_id
inner join products on
	sales.product_id = products.product_id
group by employees.first_name, employees.last_name
order by income desc
limit 10;


-- Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. Таблица отсортирована по выручке по возрастанию.

select
    employees.first_name || ' ' || employees.last_name AS seller,
    FLOOR(SUM(sales.quantity * products.price) / COUNT(sales.sales_id)) AS average_income
from employees
inner join sales on employees.employee_id = sales.sales_person_id
inner join products on sales.product_id = products.product_id
group by employees.first_name, employees.last_name
HAVING (SUM(sales.quantity * products.price) / COUNT(sales.sales_id)) <
       (
         SELECT SUM(sales.quantity * products.price) / COUNT(sales.sales_id)
         FROM sales
         INNER JOIN products ON sales.product_id = products.product_id
       )
order by average_income ASC;


-- Третий отчет содержит информацию о выручке по дням недели. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку. Отсортируйте данные по порядковому номеру дня недели и seller

select
	employees.first_name || ' ' || employees.last_name AS seller,
	TO_CHAR(sales.sale_date, 'Day') AS day_of_week,
	FLOOR(SUM(products.price * sales.quantity)) as income
from sales
inner join employees on employees.employee_id = sales.sales_person_id
inner join products on sales.product_id = products.product_id
group by employees.first_name, employees.last_name, TO_CHAR(sales.sale_date, 'Day'), EXTRACT(DOW FROM sales.sale_date)
order by EXTRACT(DOW FROM sales.sale_date), seller asc;

-- отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. Итоговая таблица должна быть отсортирована по возрастным группам и содержать следующие поля:
select
  age_category,
  age_count
from (
  SELECT
    CASE
      WHEN customers.age BETWEEN 16 AND 25 THEN '16-25'
      WHEN customers.age BETWEEN 26 AND 40 THEN '26-40'
      WHEN customers.age > 40 THEN '40+'
      ELSE 'unknown'
    END AS age_category,
    COUNT(customers.customer_id) AS age_count
  from customers
  group by
    CASE
      WHEN customers.age BETWEEN 16 AND 25 THEN '16-25'
      WHEN customers.age BETWEEN 26 AND 40 THEN '26-40'
      WHEN customers.age > 40 THEN '40+'
      ELSE 'unknown'
    end
) as categories
order by
  CASE age_category
    WHEN '16-25' THEN 1
    WHEN '26-40' THEN 2
    WHEN '40+' THEN 3
    ELSE 4
  end;


--Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке, которую они принесли.
--Сгруппируйте данные по дате, которая представлена в числовом виде ГОД-МЕСЯЦ.
--Итоговая таблица должна быть отсортирована по дате по возрастанию и содержать следующие поля:
select
	EXTRACT(YEAR FROM sales.sale_date) * 100 + EXTRACT(MONTH FROM sales.sale_date) AS date,
	count(distinct customers.customer_id) as total_customers,
	FLOOR(sum(products.price * sales.quantity)) as income
from sales
inner join customers on customers.customer_id = sales.customer_id
inner join products on sales.product_id = products.product_id
group by EXTRACT(YEAR FROM sales.sale_date) * 100 + EXTRACT(MONTH FROM sales.sale_date)
order by date asc;


--Третий отчет следует составить о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0).
--Итоговая таблица должна быть отсортирована по id покупателя. Таблица состоит из следующих полей:
SELECT
    customers.first_name || ' ' || customers.last_name AS customer,
    sales.sale_date,
    employees.first_name || ' ' || employees.last_name AS seller
FROM (
    SELECT
        sales.*,
        ROW_NUMBER() OVER (
            PARTITION BY sales.customer_id
            ORDER BY sales.sale_date
        ) AS rn
    FROM sales
    INNER JOIN products ON products.product_id = sales.product_id
    WHERE products.price = 0
) AS sales
INNER JOIN customers ON customers.customer_id = sales.customer_id
INNER JOIN employees ON employees.employee_id = sales.sales_person_id
WHERE rn = 1
order by customers.customer_id;