
-- Create View for clean orders (only delivered orders with valid dates)
CREATE VIEW core.fact_orders_view AS
SELECT *
FROM core.fact_orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_delivered_carrier_date IS NOT NULL
AND order_delivered_customer_date >= order_purchase_timestamp
AND order_delivered_carrier_date >= order_purchase_timestamp
AND order_delivered_customer_date >= order_delivered_carrier_date;



-- create a view for delivered orders with correcponding reviews
CREATE VIEW core.fact_orders_reviews_view AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    r.review_id,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message,
    r.review_creation_date
FROM core.fact_orders_clean o
INNER JOIN core.fact_order_reviews r ON o.order_id = r.order_id;



-- create a view for delivered orders with only the most recent review (if there are duplicates)
CREATE VIEW core.fact_orders_reviews_view_clean AS
SELECT DISTINCT ON (order_id)
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    review_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date
FROM core.fact_orders_reviews_view
ORDER BY order_id, review_creation_date DESC;



-- create geolocation view with average lat and lng by zip code prefix
-- this would collapse multiple geolocation records for the same zip code
-- prefix into a single record with the average lat and lng, which can be useful
-- for analysis at the zip code level.
CREATE VIEW core.dim_geolocation_view AS
SELECT geolocation_zip_code_prefix,
        AVG(geolocation_lat) AS avg_lat,
        AVG(geolocation_lng) AS avg_lng
FROM core.dim_geolocation
GROUP BY geolocation_zip_code_prefix;



-- create a view to analyze the relationship between seller dispatch times, 
--carrier delivery times, and review scores for the seller with the lowest ratings
CREATE VIEW core.seller_dispatch_analysis AS
SELECT
    orv.order_id,
    orv.review_score,
    orv.order_purchase_timestamp,
    orv.order_delivered_carrier_date,
    orv.order_delivered_customer_date,
    orv.order_estimated_delivery_date,
    -- how long seller took to dispatch
    EXTRACT(DAY FROM orv.order_delivered_carrier_date - 
            orv.order_purchase_timestamp) AS seller_dispatch_days,
    -- how long carrier took to deliver
    EXTRACT(DAY FROM orv.order_delivered_customer_date - 
            orv.order_delivered_carrier_date) AS carrier_delivery_days,
    -- how long it took to deliver compared to the estimated delivery date
    EXTRACT(DAY FROM orv.order_estimated_delivery_date - 
        orv.order_purchase_timestamp) AS estimated_delivery_days,
    -- how long it actually took to deliver
    EXTRACT(DAY FROM orv.order_delivered_customer_date - 
        orv.order_purchase_timestamp) AS actual_delivery_days,
    -- was it delivered late
    CASE WHEN orv.order_delivered_customer_date > 
              orv.order_estimated_delivery_date 
         THEN 'Late' 
         ELSE 'On Time' 
    END AS delivery_status
FROM core.fact_orders_reviews_view_clean orv
INNER JOIN core.fact_order_items oi ON orv.order_id = oi.order_id
WHERE oi.seller_id = 'b1b3948701c5c72445495bd161b83a4c'
ORDER BY orv.review_score ASC;


-- VIEWS FOR PYTHON 
-- Use this View for Python analysis to compare the low review seller's delivery across 14 orders
-- The 5 On-time and 9 late deliveries
CREATE VIEW core.seller_dispatch_analysis_view AS
SELECT 
    review_score,
    seller_dispatch_days,
    carrier_delivery_days,
    actual_delivery_days,
    estimated_delivery_days,
    delivery_status
FROM core.seller_dispatch_analysis
ORDER BY review_score ASC;



-- Use this View for Python analysis to compare the low review seller's 
--dispatch and delivery times to the platform average
CREATE VIEW core.seller_vs_platform_view AS
SELECT
    'This Seller' AS seller_label,
    ROUND(AVG(seller_dispatch_days)::NUMERIC, 2) AS avg_dispatch_days,
    ROUND(AVG(carrier_delivery_days)::NUMERIC, 2) AS avg_carrier_days,
    ROUND(AVG(actual_delivery_days)::NUMERIC, 2) AS avg_actual_days
FROM core.seller_dispatch_analysis
UNION ALL
SELECT
    'Platform Average' AS seller_label,
    ROUND(AVG(EXTRACT(DAY FROM o.order_delivered_carrier_date - 
            o.order_purchase_timestamp))::NUMERIC, 2) AS avg_dispatch_days,
    ROUND(AVG(EXTRACT(DAY FROM o.order_delivered_customer_date - 
            o.order_delivered_carrier_date))::NUMERIC, 2) AS avg_carrier_days,
    ROUND(AVG(EXTRACT(DAY FROM o.order_delivered_customer_date - 
            o.order_purchase_timestamp))::NUMERIC, 2) AS avg_actual_days
FROM core.fact_orders_reviews_view_clean o;



-- Use this View for Python analysis to compare the low review seller's 
--review scores and review comments
CREATE VIEW core.seller_reviews_comments_view AS
SELECT sda.review_score, delivery_status, review_comment_message
FROM core.fact_orders_reviews_view_clean orv
INNER JOIN core.fact_order_items oi ON orv.order_id = oi.order_id
INNER JOIN core.seller_dispatch_analysis sda ON orv.order_id = sda.order_id
WHERE oi.seller_id = 'b1b3948701c5c72445495bd161b83a4c'