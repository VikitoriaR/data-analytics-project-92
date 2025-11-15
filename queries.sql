-- Count unique customers
SELECT
    COUNT(DISTINCT customer_id) AS customers_count
FROM
    customers;

-- Sellers, number of operations and income
SELECT
    CONCAT(
        empl.first_name,
        ' ',
        empl.last_name
    ) AS seller,
    COUNT(sales.sales_person_id) AS operations,
    FLOOR(
        SUM(sales.quantity * prod.price)
    ) AS income
FROM
    sales
INNER JOIN
    employees AS empl
    ON sales.sales_person_id = empl.employee_id
INNER JOIN
    products AS prod
    ON sales.product_id = prod.product_id
GROUP BY
    seller
ORDER BY
    income DESC
LIMIT 10;


-- Sellers with avg income lower than general avg
WITH tab AS (
    SELECT
        CONCAT(
            empl.first_name,
            ' ',
            empl.last_name
        ) AS seller,
        FLOOR(
            AVG(sales.quantity * prod.price)
        ) AS avg_sales,
        SUM(sales.quantity * prod.price) AS income
    FROM
        sales
    INNER JOIN
        employees AS empl
        ON sales.sales_person_id = empl.employee_id
    INNER JOIN
        products AS prod
        ON sales.product_id = prod.product_id
    GROUP BY
        seller
)

SELECT
    tab.seller,
    tab.avg_sales AS average_income
FROM
    tab
WHERE
    tab.avg_sales < (
        SELECT
            FLOOR(
                AVG(sales.quantity * prod.price)
            )
        FROM
            sales
        INNER JOIN
            employees AS empl
            ON sales.sales_person_id = empl.employee_id
        INNER JOIN
            products AS prod
            ON sales.product_id = prod.product_id
    )
ORDER BY
    tab.average_income ASC;


-- Income by days of week
SELECT
    CONCAT(
        empl.first_name,
        ' ',
        empl.last_name
    ) AS seller,
    TRIM(
        TO_CHAR(sales.sale_date, 'day')
    ) AS day_of_week,
    FLOOR(
        SUM(sales.quantity * prod.price)
    ) AS income
FROM
    sales
INNER JOIN
    employees AS empl
    ON sales.sales_person_id = empl.employee_id
INNER JOIN
    products AS prod
    ON sales.product_id = prod.product_id
GROUP BY
    seller,
    day_of_week,
    EXTRACT(ISODOW FROM sales.sale_date)
ORDER BY
    EXTRACT(ISODOW FROM sales.sale_date),
    seller;


-- Customers by age groups
WITH tab AS (
    SELECT
        *,
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            WHEN age > 40 THEN '40+'
        END AS age_category
    FROM
        customers
)

SELECT
    tab.age_category,
    COUNT(tab.age_category) AS age_count
FROM
    tab
GROUP BY
    tab.age_category
ORDER BY
    tab.age_category;


-- Customers whose first purchase occurred during event
WITH tab AS (
    SELECT
        sales.*,
        TO_CHAR(
            DATE_TRUNC('month', sales.sale_date),
            'yyyy-mm'
        ) AS selling_month,
        MIN(sales.sale_date) OVER (
            PARTITION BY sales.customer_id
        ) AS minsaledate,
        sales.quantity * prod.price AS income,
        CONCAT(
            cust.first_name,
            ' ',
            cust.last_name
        ) AS custname,
        CONCAT(
            empl.first_name,
            ' ',
            empl.last_name
        ) AS salespname
    FROM
        sales
    INNER JOIN
        products AS prod
        ON sales.product_id = prod.product_id
    INNER JOIN
        customers AS cust
        ON sales.customer_id = cust.customer_id
    INNER JOIN
        employees AS empl
        ON sales.sales_person_id = empl.employee_id
)

SELECT
    tab.custname AS customer,
    tab.sale_date,
    tab.salespname AS seller
FROM
    tab
WHERE
    tab.sale_date = tab.minsaledate
    AND tab.income = 0
GROUP BY
    tab.custname,
    tab.sale_date,
    tab.salespname,
    tab.customer_id
ORDER BY
    tab.customer_id ASC;
