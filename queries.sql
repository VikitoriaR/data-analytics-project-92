-- Считаем общее количество покупателей из таблицы customers.
SELECT
    COUNT(DISTINCT customer_id) AS customers_count
FROM customers;

-- Продавец, сделки и прибыль
SELECT
    CONCAT(empl.first_name, ' ', empl.last_name) AS seller,
    COUNT(sales.sales_person_id) AS operations,
    FLOOR(SUM(sales.quantity * prod.price)) AS income
FROM sales
    INNER JOIN employees AS empl ON sales.sales_person_id = empl.employee_id
    INNER JOIN products AS prod ON sales.product_id = prod.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10;

-- Продавцы с выручкой ниже средней
WITH tab AS (
    SELECT
        CONCAT(empl.first_name, ' ', empl.last_name) AS seller,
        FLOOR(AVG(sales.quantity * prod.price)) AS avg_sales,
        SUM(sales.quantity * prod.price) AS income
    FROM sales
        INNER JOIN employees AS empl ON sales.sales_person_id = empl.employee_id
        INNER JOIN products AS prod ON sales.product_id = prod.product_id
    GROUP BY seller
)

SELECT
    seller,
    avg_sales AS average_income
FROM tab
WHERE avg_sales < (
    SELECT
        FLOOR(AVG(sales.quantity * prod.price))
    FROM sales
        INNER JOIN employees AS empl ON sales.sales_person_id = empl.employee_id
        INNER JOIN products AS prod ON sales.product_id = prod.product_id
)
ORDER BY average_income ASC;

-- Выручка по дням недели
SELECT
    CONCAT(empl.first_name, ' ', empl.last_name) AS seller,
    TRIM(TO_CHAR(sales.sale_date, 'day')) AS day_of_week,
    FLOOR(SUM(sales.quantity * prod.price)) AS income
FROM sales
    INNER JOIN employees AS empl ON sales.sales_person_id = empl.employee_id
    INNER JOIN products AS prod ON sales.product_id = prod.product_id
GROUP BY
    seller,
    day_of_week,
    EXTRACT(ISODOW FROM sales.sale_date)
ORDER BY
    EXTRACT(ISODOW FROM sales.sale_date),
    seller;

-- Покупатели по возрастным группам
WITH tab AS (
    SELECT
        *,
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category
    FROM customers
)

SELECT
    age_category,
    COUNT(age_category) AS age_count
FROM tab
GROUP BY age_category
ORDER BY age_category;

-- Количество уникальных покупателей
WITH tab AS (
    SELECT
        *,
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category
    FROM customers
)

SELECT
    age_category,
    COUNT(age_category) AS age_count
FROM tab
GROUP BY age_category
ORDER BY age_category;

-- Покупатели, первая покупка которых пришлась на время проведения акции
WITH tab AS (
    SELECT
        sales.*,
        TO_CHAR(DATE_TRUNC('month', sales.sale_date), 'yyyy-mm') AS selling_month,
        MIN(sale_date) OVER (PARTITION BY sales.customer_id) AS minsaledate,
        sales.quantity * prod.price AS income,
        CONCAT(cust.first_name, ' ', cust.last_name) AS custname,
        CONCAT(empl.first_name, ' ', empl.last_name) AS salespname
    FROM sales
        INNER JOIN products AS prod ON sales.product_id = prod.product_id
        INNER JOIN customers AS cust ON sales.customer_id = cust.customer_id
        INNER JOIN employees AS empl ON sales.sales_person_id = empl.employee_id
)

SELECT
    custname AS customer,
    sale_date,
    salespname AS seller
FROM tab
WHERE sale_date = minsaledate
    AND income = 0
GROUP BY
    custname,
    sale_date,
    salespname,
    customer_id
ORDER BY customer_id ASC;