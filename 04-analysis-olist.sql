
-- DATA CLEANING
-- Check for missing dates in core_fact_orders table
SELECT
    COUNT(*) AS total_orders,
    -- purchase timestamp
    COUNT(order_purchase_timestamp) AS has_purchase_date,
    COUNT(*) - COUNT(order_purchase_timestamp) AS missing_purchase_date,
    -- approved at
    COUNT(order_approved_at) AS has_approved_date,
    COUNT(*) - COUNT(order_approved_at) AS missing_approved_date,
    -- delivered to carrier
    COUNT(order_delivered_carrier_date) AS has_carrier_date,
    COUNT(*) - COUNT(order_delivered_carrier_date) AS missing_carrier_date,
    -- delivered to customer
    COUNT(order_delivered_customer_date) AS has_delivery_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date,
    -- estimated delivery
    COUNT(order_estimated_delivery_date) AS has_estimated_date,
    COUNT(*) - COUNT(order_estimated_delivery_date) AS missing_estimated_date
FROM core.fact_orders;

-- check for missing delivery dates for delivered orders
SELECT COUNT(*) 
FROM core.fact_orders
WHERE order_delivered_customer_date::TEXT = '';

-- check for missing delivery dates by order status
SELECT 
    order_status,
    COUNT(*) AS total,
    COUNT(order_delivered_customer_date) AS has_delivery_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date
FROM core.fact_orders
GROUP BY order_status
ORDER BY total DESC;

-- check for delivered orders with missing delivery dates
SELECT * FROM core.fact_orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;

-- check for missing delivery dates for delivered orders
SELECT COUNT(*) 
FROM core.fact_orders
WHERE order_delivered_customer_date::TEXT = '';

-- check for missing dates by order status 'delivered'
SELECT 
    order_status,
    COUNT(*) AS total,
    -- carrier date
    COUNT(order_delivered_carrier_date) AS has_carrier_date,
    COUNT(*) - COUNT(order_delivered_carrier_date) AS missing_carrier_date,
    -- customer delivery date
    COUNT(order_delivered_customer_date) AS has_delivery_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date,
    -- approved date
    COUNT(order_approved_at) AS has_approved_date,
    COUNT(*) - COUNT(order_approved_at) AS missing_approved_date
FROM core.fact_orders
GROUP BY order_status
ORDER BY total DESC;

-- check the count of orders
SELECT count(*) FROM core.fact_orders;

-- check the distinct order statuses to see if there are any unexpected values
SELECT DISTINCT order_status FROM core.fact_orders;


-- check for impossible dates (e.g. delivered before purchased, or delivered to customer before carrier received it)
SELECT COUNT(*) AS impossible_dates
FROM core.fact_orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_delivered_carrier_date IS NOT NULL
AND (
    -- delivered before purchased
    order_delivered_customer_date < order_purchase_timestamp
    OR
    -- carrier received before purchase
    order_delivered_carrier_date < order_purchase_timestamp
    OR
    -- delivered to customer before carrier received it
    order_delivered_customer_date < order_delivered_carrier_date
);


-- check the records with impossible dates to see if there are any patterns
select order_delivered_customer_date, order_delivered_carrier_date, order_purchase_timestamp
from core.fact_orders
where order_delivered_customer_date < order_purchase_timestamp;

-- check the records with impossible dates to see if there are any patterns
select order_delivered_customer_date, order_delivered_carrier_date, order_purchase_timestamp
from core.fact_orders
where order_delivered_carrier_date < order_purchase_timestamp;

-- check the records with impossible dates to see if there are any patterns
select order_delivered_customer_date, order_delivered_carrier_date, order_purchase_timestamp
from core.fact_orders
where order_delivered_customer_date < order_delivered_carrier_date;


-- check reviews count by review score
SELECT review_score, COUNT(*) AS review_count
FROM core.fact_order_reviews
GROUP BY review_score
ORDER BY review_score DESC;

-- check the distribution of review scores for delivered orders with reviews
SELECT * FROM core.fact_order_reviews;

-- check how many reviews are in the order_reviews table
SELECT COUNT(review_id) AS total_reviews
FROM core.fact_order_reviews;

-- check the clean orders view
SELECT * FROM core.fact_orders_clean;


-- see how many orders are in the clean view
SELECT COUNT(*) FROM core.fact_orders_clean;

-- check how the number of reviews compares to the number of delivered orders
SELECT 
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN r.review_id IS NOT NULL 
          THEN o.order_id END) AS has_review,
    COUNT(DISTINCT CASE WHEN r.review_id IS NULL 
          THEN o.order_id END) AS missing_review
FROM core.fact_orders_clean o
LEFT JOIN core.fact_order_reviews r ON o.order_id = r.order_id;


/* 95636 reviews for 96281 delivered orders, so about 99.4% of delivered orders have reviews,
which is very high and suggests that there may be some data quality issues with the reviews
 table (e.g. duplicate reviews, or reviews for orders that were not actually delivered).
We should investigate this further before using the reviews data for analysis.

For the purposes of this project, I will keep all reviews in the fact_order_reviews table, 
but will be cautious when analyzing the reviews data and will consider filtering out any reviews
 that do not have a corresponding delivered order in the fact_orders_clean view by using 
 an INNER JOIN instead of a LEFT JOIN when analyzing reviews in relation to delivered orders.
*/



- DATA CLEANING
-- Check for missing dates in core_fact_orders table
SELECT
    COUNT(*) AS total_orders,
    -- purchase timestamp
    COUNT(order_purchase_timestamp) AS has_purchase_date,
    COUNT(*) - COUNT(order_purchase_timestamp) AS missing_purchase_date,
    -- approved at
    COUNT(order_approved_at) AS has_approved_date,
    COUNT(*) - COUNT(order_approved_at) AS missing_approved_date,
    -- delivered to carrier
    COUNT(order_delivered_carrier_date) AS has_carrier_date,
    COUNT(*) - COUNT(order_delivered_carrier_date) AS missing_carrier_date,
    -- delivered to customer
    COUNT(order_delivered_customer_date) AS has_delivery_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date,
    -- estimated delivery
    COUNT(order_estimated_delivery_date) AS has_estimated_date,
    COUNT(*) - COUNT(order_estimated_delivery_date) AS missing_estimated_date
FROM core.fact_orders;

-- check for missing delivery dates for delivered orders
SELECT COUNT(*) 
FROM core.fact_orders
WHERE order_delivered_customer_date::TEXT = '';

-- check for missing delivery dates by order status
SELECT 
    order_status,
    COUNT(*) AS total,
    COUNT(order_delivered_customer_date) AS has_delivery_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date
FROM core.fact_orders
GROUP BY order_status
ORDER BY total DESC;

-- check for delivered orders with missing delivery dates
SELECT * FROM core.fact_orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;

-- check for missing delivery dates for delivered orders
SELECT COUNT(*) 
FROM core.fact_orders
WHERE order_delivered_customer_date::TEXT = '';

-- check for missing dates by order status 'delivered'
SELECT 
    order_status,
    COUNT(*) AS total,
    -- carrier date
    COUNT(order_delivered_carrier_date) AS has_carrier_date,
    COUNT(*) - COUNT(order_delivered_carrier_date) AS missing_carrier_date,
    -- customer delivery date
    COUNT(order_delivered_customer_date) AS has_delivery_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date,
    -- approved date
    COUNT(order_approved_at) AS has_approved_date,
    COUNT(*) - COUNT(order_approved_at) AS missing_approved_date
FROM core.fact_orders
GROUP BY order_status
ORDER BY total DESC;

-- check the count of orders
SELECT count(*) FROM core.fact_orders;

-- check the distinct order statuses to see if there are any unexpected values
SELECT DISTINCT order_status FROM core.fact_orders;

-- check for impossible dates (e.g. delivered before purchased, or delivered to customer before carrier received it)
SELECT COUNT(*) AS impossible_dates
FROM core.fact_orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_delivered_carrier_date IS NOT NULL
AND (
    -- delivered before purchased
    order_delivered_customer_date < order_purchase_timestamp
    OR
    -- carrier received before purchase
    order_delivered_carrier_date < order_purchase_timestamp
    OR
    -- delivered to customer before carrier received it
    order_delivered_customer_date < order_delivered_carrier_date
);

-- check the records with impossible dates to see if there are any patterns
select order_delivered_customer_date, order_delivered_carrier_date, order_purchase_timestamp
from core.fact_orders
where order_delivered_customer_date < order_purchase_timestamp;

-- check the records with impossible dates to see if there are any patterns
select order_delivered_customer_date, order_delivered_carrier_date, order_purchase_timestamp
from core.fact_orders
where order_delivered_carrier_date < order_purchase_timestamp;

-- check the records with impossible dates to see if there are any patterns
select order_delivered_customer_date, order_delivered_carrier_date, order_purchase_timestamp
from core.fact_orders
where order_delivered_customer_date < order_delivered_carrier_date;



--Join delivered orders and reviews to filter out reviews without delivered orders
SELECT 
    COUNT(*) AS delivered_orders,
    COUNT(r.review_id) AS has_review,
    COUNT(*) - COUNT(r.review_id) AS missing_review
FROM core.fact_orders_clean o
INNER JOIN core.fact_order_reviews r ON o.order_id = r.order_id;


-- check the view for delivered orders with reviews
SELECT * FROM core.fact_orders_reviews_view;

-- check how many records are in the view for delivered orders with reviews
SELECT COUNT(*) FROM core.fact_orders_reviews_view;

-- check for duplicate reviews for the same order
SELECT 
    order_id,
    COUNT(*) AS review_count
FROM core.fact_orders_reviews_view
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY review_count DESC;

-- Use a CTE to check for duplicate reviews for the same order
WITH duplicate_reviews AS(
    SELECT 
        order_id,
        COUNT(*) AS review_count
    FROM core.fact_orders_reviews_view
    GROUP BY order_id
    HAVING COUNT(*) > 1 
)
SELECT SUM(review_count) AS total_duplicate_reviews
FROM duplicate_reviews;


-- check the clean view for delivered orders with reviews
SELECT COUNT(*) AS total_reviews_clean
FROM core.fact_orders_reviews_view_clean;

-- see the clean view for delivered orders with reviews
SELECT * FROM core.fact_orders_reviews_view_clean;

-- ANALYSIS
-- check sellers with the lowest ratings
SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state,
    AVG(r.review_score) AS average_review_score,
    COUNT(r.review_id) AS total_reviews
FROM core.dim_sellers s
JOIN core.fact_order_items oi ON s.seller_id = oi.seller_id
JOIN core.fact_orders_reviews_view_clean r ON oi.order_id = r.order_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY average_review_score ASC;

-- check sellers with the lowest ratings and at least 10 reviews
-- A seller can have multiple orders, but we want to focus on sellers with 
-- a significant number of reviews to ensure the average rating is reliable.
SELECT 
    oi.seller_id,
    ROUND(AVG(orv.review_score), 2) AS avg_rating,
    COUNT(DISTINCT orv.order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN orv.review_score <= 2
          THEN orv.order_id END) AS low_rating_orders
FROM core.fact_orders_reviews_view_clean orv
INNER JOIN core.fact_order_items oi ON orv.order_id = oi.order_id
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT orv.order_id) >= 10
ORDER BY avg_rating ASC
LIMIT 10;


-- view the geolocation data
SELECT * FROM dim_geolocation;
SELECT COUNT(*) FROM dim_geolocation


-- see the geolocation view with average lat and lng by zip code prefix
SELECT * FROM core.dim_geolocation_view;
-- check how many records are in the geolocation view

SELECT COUNT(*) FROM core.dim_geolocation_view;


-- Using a CTE to calculate the distance between the seller and customer for each order,
-- and then check if there is any relationship between distance and review scores for the seller with the lowest ratings
WITH seller_coords AS (
    SELECT
        s.seller_id,
        g.avg_lat AS seller_lat,
        g.avg_lng AS seller_lng
    FROM core.dim_sellers s
    INNER JOIN core.dim_geolocation_view g 
        ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
    WHERE s.seller_id = 'b1b3948701c5c72445495bd161b83a4c'
),
customer_coords AS (
    SELECT
        o.order_id,
        g.avg_lat AS customer_lat,
        g.avg_lng AS customer_lng
    FROM core.fact_orders_reviews_view_clean o
    INNER JOIN core.dim_customers c ON o.customer_id = c.customer_id
    INNER JOIN core.dim_geolocation_view g 
        ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
)
SELECT
    orv.order_id,
    orv.review_score,
    ROUND(2 * 6371 * ASIN(
        SQRT(
            POWER(SIN(RADIANS(sc.seller_lat - cc.customer_lat) / 2), 2) +
            COS(RADIANS(sc.seller_lat)) *
            COS(RADIANS(cc.customer_lat)) *
            POWER(SIN(RADIANS(sc.seller_lng - cc.customer_lng) / 2), 2)
        )
    ):: NUMERIC, 2) AS distance_km
FROM core.fact_orders_reviews_view_clean orv
INNER JOIN core.fact_order_items oi ON orv.order_id = oi.order_id
INNER JOIN customer_coords cc ON orv.order_id = cc.order_id
INNER JOIN seller_coords sc ON oi.seller_id = sc.seller_id;


-- Using a CTE to check the average review score by distance from the seller to the customer
WITH seller_coords AS (
    SELECT
        s.seller_id,
        g.avg_lat AS seller_lat,
        g.avg_lng AS seller_lng
    FROM core.dim_sellers s
    INNER JOIN core.dim_geolocation_view g 
        ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
),  
customer_coords AS (
    SELECT
        o.order_id,
        g.avg_lat AS customer_lat,
        g.avg_lng AS customer_lng
    FROM core.fact_orders_reviews_view_clean o
    INNER JOIN core.dim_customers c ON o.customer_id = c.customer_id
    INNER JOIN core.dim_geolocation_view g 
        ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
),
order_distances AS (
    SELECT
        orv.order_id,
        orv.review_score,
        2 * 6371 * ASIN(
            SQRT(
                POWER(SIN(RADIANS(sc.seller_lat - cc.customer_lat) / 2), 2) +
                COS(RADIANS(sc.seller_lat)) *
                COS(RADIANS(cc.customer_lat)) *
                POWER(SIN(RADIANS(sc.seller_lng - cc.customer_lng) / 2), 2)
            )
        ) AS distance_km
    FROM core.fact_orders_reviews_view_clean orv
    INNER JOIN core.fact_order_items oi ON orv.order_id = oi.order_id
    INNER JOIN customer_coords cc ON orv.order_id = cc.order_id
    INNER JOIN seller_coords sc ON oi.seller_id = sc.seller_id
)  
SELECT 
    CASE 
    WHEN distance_km <= 50 THEN '0-50 km'
    WHEN distance_km <= 100 THEN '51-100 km'
    WHEN distance_km <= 150 THEN '101-150 km'
    WHEN distance_km <= 200 THEN '151-200 km'
    WHEN distance_km <= 250 THEN '201-250 km'
    WHEN distance_km <= 300 THEN '251-300 km'
    WHEN distance_km <= 400 THEN '301-400 km'
    ELSE '401+ km'
END AS distance_range,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    COUNT(*) AS total_reviews
FROM order_distances
GROUP BY distance_range
ORDER BY avg_review_score ASC;


SELECT * FROM core.seller_dispatch_analysis;

-- check the relationship between delivery times and review scores for the seller with the lowest ratings
SELECT review_score,
       seller_dispatch_days,
       carrier_delivery_days,
       estimated_delivery_days,
       actual_delivery_days,
       delivery_status
FROM core.seller_dispatch_analysis
ORDER BY review_score ASC;

-- check the average delivery times for the seller with the lowest ratings
SELECT
    ROUND(AVG(seller_dispatch_days)::NUMERIC, 2) AS avg_seller_dispatch_days,
    ROUND(AVG(carrier_delivery_days)::NUMERIC, 2) AS avg_carrier_delivery_days,
    ROUND(AVG(actual_delivery_days)::NUMERIC, 2) AS avg_actual_days,
    ROUND(AVG(estimated_delivery_days)::NUMERIC, 2) AS avg_estimated_days,
    COUNT(*) AS total_orders
FROM core.seller_dispatch_analysis
--GROUP BY delivery_status, review_score
--ORDER BY review_score ASC, delivery_status;


-- check the low review seller's average delivery times and review scores for on time vs late deliveries
SELECT
    delivery_status,
    review_score,
    ROUND(AVG(seller_dispatch_days)::NUMERIC, 2) AS avg_seller_dispatch_days,
    ROUND(AVG(carrier_delivery_days)::NUMERIC, 2) AS avg_carrier_delivery_days,
    ROUND(AVG(actual_delivery_days)::NUMERIC, 2) AS avg_actual_days,
    ROUND(AVG(estimated_delivery_days)::NUMERIC, 2) AS avg_estimated_days,
    COUNT(*) AS total_orders
FROM core.seller_dispatch_analysis
GROUP BY delivery_status, review_score
ORDER BY review_score ASC, delivery_status;


-- average platform seller dispatch days, carrier delivery days, and 
-- actual delivery days for all delivered orders with reviews
SELECT
    ROUND(AVG(
        EXTRACT(DAY FROM order_delivered_carrier_date - 
                order_purchase_timestamp))::NUMERIC, 2) AS platform_avg_dispatch_days,
    ROUND(AVG(
        EXTRACT(DAY FROM order_delivered_customer_date - 
                order_delivered_carrier_date))::NUMERIC, 2) AS platform_avg_carrier_days,
    ROUND(AVG(
        EXTRACT(DAY FROM order_delivered_customer_date - 
                order_purchase_timestamp))::NUMERIC, 2) AS platform_avg_actual_days
FROM core.fact_orders_reviews_view_clean;



-- check the clean view for delivered orders with reviews
SELECT COUNT(*) AS total_reviews_clean
FROM core.fact_orders_reviews_view_clean;

-- see the clean view for delivered orders with reviews
SELECT * FROM core.fact_orders_reviews_view_clean;


/* from the analysis, the distance between the seller and the customers does not seem to be a significant
factor in the low review scores. 
It appears that the low review seller has much longer dispatch times than the platform average,
which suggests that the seller's dispatch times may be a key driver of the low review scores.
The carrier delivery times for the low review seller are also longer than the platform average, but the
difference is not as large as for the dispatch times, which suggests that the carrier delivery times 
may be less of a factor in the low review scores compared to the seller's dispatch times.
*/



-- check the seller dispatch analysis view
SELECT * FROM core.seller_dispatch_analysis_view;

SELECT * FROM core.seller_vs_platform_view;

SELECT * FROM core.seller_reviews_comments_view;


