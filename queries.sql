-- Считаем общее количество покупателей из таблицы customers.
select
    count(distinct customer_id) as customers_count
from customers;

-- Продавец, сделки и прибыль.
select
    concat(empl.first_name, ' ', empl.last_name) as seller,
    count(sales.sales_person_id) as operations,
    floor(sum(sales.quantity * prod.price)) as income
from sales
inner join employees as empl
    on sales.sales_person_id = empl.employee_id
inner join products as prod
    on sales.product_id = prod.product_id
group by seller
order by income desc
limit 10;

-- Продавцы, чья средняя выручка за сделку меньше средней по всем.
with tab as (
    select
        concat(empl.first_name, ' ', empl.last_name) as seller,
        floor(avg(sales.quantity * prod.price)) as avg_sales,
        sum(sales.quantity * prod.price) as income
    from sales
    inner join employees as empl
        on sales.sales_person_id = empl.employee_id
    inner join products as prod
        on sales.product_id = prod.product_id
    group by seller
)
select
    seller,
    avg_sales as average_income
from tab
where avg_sales < (
    select
        floor(avg(sales.quantity * prod.price))
    from sales
    inner join employees as empl
        on sales.sales_person_id = empl.employee_id
    inner join products as prod
        on sales.product_id = prod.product_id
)
order by average_income asc;

-- Выручки по дням недели.
select
    concat(empl.first_name, ' ', empl.last_name) as seller,
    trim(to_char(sales.sale_date, 'day')) as day_of_week,
    floor(sum(sales.quantity * prod.price)) as income
from sales
inner join employees as empl
    on sales.sales_person_id = empl.employee_id
inner join products as prod
    on sales.product_id = prod.product_id
group by
    seller,
    day_of_week,
    extract(isodow from sales.sale_date)
order by
    extract(isodow from sales.sale_date),
    seller;

-- Покупатели по возрастным группам.
with tab as (
    select
        *,
        case
            when age between 16 and 25 then '16-25'
            when age between 26 and 40 then '26-40'
            when age > 40 then '40+'
        end as age_category
    from customers
)
select
    age_category,
    count(age_category) as age_count
from tab
group by age_category
order by age_category;

-- Количество уникальных покупателей по возрастным группам.
with tab as (
    select
        *,
        case
            when age between 16 and 25 then '16-25'
            when age between 26 and 40 then '26-40'
            when age > 40 then '40+'
        end as age_category
    from customers
)
select
    age_category,
    count(distinct customer_id) as unique_customers
from tab
group by age_category
order by age_category;

-- Покупатели, первая покупка которых пришлась на время проведения
with tab as (
    select
        sales.*,
        to_char(
            date_trunc('month', sales.sale_date),
            'yyyy-mm'
        ) as selling_month,
        min(sale_date) over (
            partition by sales.customer_id
        ) as minsaledate,
        sales.quantity * prod.price as income,
        concat(cust.first_name, ' ', cust.last_name) as custname,
        concat(empl.first_name, ' ', empl.last_name) as salespname
    from sales
    inner join products as prod
        on sales.product_id = prod.product_id
    inner join customers as cust
        on sales.customer_id = cust.customer_id
    inner join employees as empl
        on sales.sales_person_id = empl.employee_id
)
select
    custname as customer,
    sale_date,
    salespname as seller
from tab
where
    sale_date = minsaledate
    and income = 0
group by
    custname,
    sale_date,
    salespname,
    customer_id
order by customer_id asc;