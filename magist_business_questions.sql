use magist;
-- -----

select count(order_id), order_status
from orders
group by order_status;

select * from orders
where order_status !="delivered";

select distinct state from geo
order by state;

select distinct customer_id from orders
order by customer_id;

-- How many products of these tech categories have been sold (within the time window of the database snapshot)?   
SELECT 
    COUNT(DISTINCT oi.product_id) AS n_tech_products
FROM
    order_items AS oi
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english = 'electronics'
        OR pcnt.product_category_name_english = 'computers'
        OR pcnt.product_category_name_english = 'computers_accessories'
        OR pcnt.product_category_name_english = 'audio'
        OR pcnt.product_category_name_english = 'telephony'
        OR pcnt.product_category_name_english = 'tablets_printing_image';

-- What's the average price of the products being sold?
SELECT 
    AVG(price)
FROM
    order_items;
    
-- How many sellers are there?
SELECT 
    COUNT(DISTINCT seller_id) as n_sellers
FROM
    order_items;

-- How many tech sellers are there?
SELECT 
    COUNT(DISTINCT oi.seller_id) AS n_sellers
FROM
    order_items AS oi
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english = 'electronics'
        OR pcnt.product_category_name_english = 'computers'
        OR pcnt.product_category_name_english = 'computers_accessories'
        OR pcnt.product_category_name_english = 'audio'
        OR pcnt.product_category_name_english = 'telephony'
        OR pcnt.product_category_name_english = 'tablets_printing_image';

-- What is the total amount earned by all sellers?
SELECT 
    SUM(payment_value)  as total_earnings
FROM
    order_payments;

-- What is the total amount earned by all tech sellers?
SELECT 
    SUM(op.payment_value) AS tech_earnings
FROM
    order_payments AS op
        LEFT JOIN
    orders AS o ON op.order_id = o.order_id
        LEFT JOIN
    order_items AS oi ON o.order_id = oi.order_id
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english = 'electronics'
        OR pcnt.product_category_name_english = 'computers'
        OR pcnt.product_category_name_english = 'computers_accessories'
        OR pcnt.product_category_name_english = 'audio'
        OR pcnt.product_category_name_english = 'telephony'
        OR pcnt.product_category_name_english = 'tablets_printing_image';

-- What’s the average time between the order being placed and the product being delivered?

SELECT 
    AVG(DATEDIFF(order_delivered_customer_date,
            order_approved_at)) AS average_delivery_time_in_days
FROM
    orders;

-- What’s the average time between the order being placed and the product being delivered for tech products?

SELECT 
    AVG(DATEDIFF(o.order_delivered_customer_date,
            o.order_approved_at)) AS average_delivery_time_tech
FROM
    orders as o
    LEFT JOIN
    order_items AS oi ON o.order_id = oi.order_id
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english = 'electronics'
        OR pcnt.product_category_name_english = 'computers'
        OR pcnt.product_category_name_english = 'computers_accessories'
        OR pcnt.product_category_name_english = 'audio'
        OR pcnt.product_category_name_english = 'telephony'
        OR pcnt.product_category_name_english = 'tablets_printing_image';

-- How many orders are delivered on time?
SELECT 
    COUNT(*) as orders_on_time
FROM
    orders
WHERE
    order_estimated_delivery_date > order_delivered_customer_date;

-- How many orders are delivered with a delay?
SELECT 
    COUNT(*) as orders_delayed
FROM
    orders
WHERE
    order_estimated_delivery_date < order_delivered_customer_date;
    
-- How many orders of computer accessories are actually delivered?
SELECT 
    o.order_status,
    COUNT(o.order_id) AS orders,
    pcnt.product_category_name_english
FROM
    orders AS o
        LEFT JOIN
    order_items AS oi ON o.order_id = oi.order_id
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english = 'computers_accessories'
GROUP BY o.order_status
ORDER BY orders DESC;


-- delivery time for each product:
SELECT /* delivery days for each order*/
    order_id,
    order_approved_at,
    order_delivered_customer_date,
    DATEDIFF(order_delivered_customer_date, order_approved_at) AS delivery_time_in_days
FROM
    orders;

-- delivery time for each category:
SELECT 
    pcnt.product_category_name_english,
    COUNT(o.order_id) AS orders,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_approved_at)) AS average_delivery_time_in_days
FROM
    orders AS o
        LEFT JOIN
    order_items AS oi ON o.order_id = oi.order_id
        LEFT JOIN
    products AS p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    o.order_status = 'delivered'
GROUP BY pcnt.product_category_name_english
ORDER BY orders DESC;

-- Separating tech products from other products
SELECT 
    COUNT(*),
    CASE
        WHEN product_category_name_english LIKE '%computer%' THEN 'Tech'
        WHEN product_category_name_english LIKE '%audio%' THEN 'Tech'
        WHEN product_category_name_english LIKE '%consoles_games%' THEN 'Tech'
        WHEN product_category_name_english LIKE '%electronics%' THEN 'Tech'
        WHEN product_category_name_english LIKE '%computers_accessories%' THEN 'Tech'
        WHEN product_category_name_english LIKE '%pc_gamer%' THEN 'Tech'
        WHEN product_category_name_english LIKE '%computers%' THEN 'Tech'
        WHEN product_category_name_english LIKE '%tablets_printing_image%' THEN 'Tech'
        WHEN product_category_name_english LIKE '%telephony%' THEN 'Tech'
        ELSE 'other'
    END AS big_category
FROM
    product_category_name_translation
GROUP BY big_category;
    
    
    