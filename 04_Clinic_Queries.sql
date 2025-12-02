--1. Find the revenue we got from each sales channel in a given year

SELECT 
    sales_channel,
    SUM(amount) AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

--2. Find top 10 the most valuable customers for a given year 

SELECT 
    uid AS customer_id, SUM(amount) AS total_spent
FROM
    clinic_sales
WHERE
    YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

WITH revenue AS (
    SELECT 
        DATE_FORMAT(datetime, '%Y-%m') AS month,
        SUM(amount) AS total_revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY month
),
expense AS (
    SELECT 
        DATE_FORMAT(datetime, '%Y-%m') AS month,
        SUM(amount) AS total_expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY month
)

--3. Find month wise revenue, expense, profit , status (profitable / not-profitable) for a given year

SELECT 
    r.month,
    r.total_revenue,
    e.total_expense,
    (r.total_revenue - e.total_expense) AS profit,
    CASE WHEN (r.total_revenue - e.total_expense) > 0 
         THEN 'PROFITABLE'
         ELSE 'NOT-PROFITABLE'
    END AS status
FROM revenue r
LEFT JOIN expense e ON r.month = e.month;

--4. For each city find the most profitable clinic for a given month

WITH base AS (
    SELECT
        cs.oid,
        cs.cid,
        c.city,
        DATE_FORMAT(cs.datetime, '%Y-%m') AS month,
        cs.amount
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
),
profit AS (
    SELECT
        city,
        cid,
        month,
        SUM(amount) AS revenue,
        (
            SELECT SUM(e.amount)
            FROM expenses e
            WHERE e.cid = b.cid
              AND DATE_FORMAT(e.datetime, '%Y-%m') = b.month
        ) AS expense
    FROM base b
    GROUP BY city, cid, month
),
ranked AS (
    SELECT
        city,
        cid,
        month,
        revenue,
        expense,
        RANK() OVER (PARTITION BY city, month ORDER BY (revenue - expense) DESC) AS rnk
    FROM profit
)
SELECT
    city,
    cid,
    month,
    (revenue - expense) AS profit
FROM ranked
WHERE rnk = 1;

--5. For each state find the second least profitable clinic for a given month

WITH base AS (
    SELECT
        cs.cid,
        c.state,
        DATE_FORMAT(cs.datetime, '%Y-%m') AS month,
        cs.amount
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
),
profit AS (
    SELECT
        state,
        cid,
        month,
        SUM(amount) AS revenue,
        (
            SELECT SUM(e.amount)
            FROM expenses e
            WHERE e.cid = b.cid
              AND DATE_FORMAT(e.datetime, '%Y-%m') = b.month
        ) AS expense
    FROM base b
    GROUP BY state, cid, month
),
ranked AS (
    SELECT
        state,
        cid,
        month,
        revenue,
        expense,
        DENSE_RANK() OVER (
            PARTITION BY state, month 
            ORDER BY (revenue - expense) ASC
        ) AS rnk
    FROM profit
)
SELECT 
    state,
    cid,
    month,
    (revenue - expense) AS profit
FROM ranked
WHERE rnk = 2;
