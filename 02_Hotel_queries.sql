--1. For every user in the system, get the user_id and last booked room_no 

SELECT b.user_id, b.room_no
FROM bookings b
JOIN (
    SELECT user_id, MAX(booking_date) AS last_booking
    FROM bookings
    GROUP BY user_id
) x 
ON b.user_id = x.user_id AND b.booking_date = x.last_booking;

--2. Get booking_id and total billing amount of every booking created in November, 2021 

SELECT 
    bc.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE(bc.bill_date) BETWEEN '2021-11-01' AND '2021-11-30'
GROUP BY bc.booking_id;

--3. Get bill_id and bill amount of all the bills raised in October, 2021 having bill amount >1000

SELECT 
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE(bc.bill_date) BETWEEN '2021-10-01' AND '2021-10-31'
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;

--4. Determine the most ordered and least ordered item of each month of year 2021 

WITH monthly_orders AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
        bc.item_id,
        SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, bc.item_id
),
ranked_items AS (
    SELECT 
        month,
        item_id,
        total_qty,
        RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS most_rank,
        RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS least_rank
    FROM monthly_orders
)
SELECT month, item_id, total_qty,
       CASE WHEN most_rank = 1 THEN 'MOST ORDERED'
            WHEN least_rank = 1 THEN 'LEAST ORDERED'
       END AS category
FROM ranked_items
WHERE most_rank = 1 OR least_rank = 1;

--5. Find the customers with the second highest bill value of each month of year 2021 

WITH monthly_bills AS (
    SELECT 
        DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
        b.user_id,
        bc.bill_id,
        SUM(bc.item_quantity * i.item_rate) AS bill_amount
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    JOIN bookings b ON bc.booking_id = b.booking_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, b.user_id, bc.bill_id
),
ranked_bills AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY month ORDER BY bill_amount DESC) AS bill_rank
    FROM monthly_bills
)
SELECT month, user_id, bill_id, bill_amount
FROM ranked_bills
WHERE bill_rank = 2;
