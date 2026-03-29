-- Check database
SELECT current_database();


-- Create raw OList tables

-- create customers table
CREATE TABLE raw.customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

-- create geolocation table
CREATE TABLE raw.geolocation (
    geolocation_zip_code_prefix TEXT,
    geolocation_lat TEXT,
    geolocation_lng TEXT,
    geolocation_city TEXT,
    geolocation_state TEXT
);

-- create order_items table
CREATE TABLE raw.order_items (
    order_id TEXT,
    order_item_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price TEXT,
    freight_value TEXT
);

-- create orders_payments table
CREATE TABLE raw.order_payments (
    order_id TEXT,
    payment_sequential TEXT,
    payment_type TEXT,
    payment_installments TEXT,
    payment_value TEXT
);

-- create order_reviews table
CREATE TABLE raw.order_reviews (
    review_id TEXT,
    order_id TEXT,
    review_score TEXT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TEXT,
    review_answer_timestamp TEXT
);

-- create orders table
CREATE TABLE raw.orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
)

-- create products table
CREATE TABLE raw.products (
    product_id TEXT, 
    product_category_name TEXT, 
    product_name_lenght TEXT, 
    product_description_lenght TEXT, 
    product_photos_qty TEXT, 
    product_weight_g TEXT, 
    product_length_cm TEXT, 
    product_height_cm TEXT, 
    product_width_cm TEXT
);

-- create sellers table
CREATE TABLE raw.sellers(
    seller_id TEXT,
    seller_zip_code_prefix TEXT, 
    seller_city TEXT, 
    seller_state TEXT
)

-- create product_category_name table
CREATE TABLE raw.product_category_name_translation(
    product_category_name TEXT, 
    product_category_name_english TEXT
)



-- insert into raw tables

-- Insert into raw.customers table
COPY raw.customers
FROM 'C:/Olist/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Insert into raw.geolocaton table
COPY raw.geolocation
FROM 'C:/Olist/olist_geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;


-- insert into order_items table
COPY raw.order_items
FROM 'C:/Olist/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

-- insert into orders_payments table
COPY raw.order_payments
FROM 'C:/Olist/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;

--insert into order_reviews table
COPY raw.order_reviews
FROM 'C:/Olist/olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;

-- insert into orders table
COPY raw.orders
FROM 'C:/Olist/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;

-- insert into products table
COPY raw.products
FROM 'C:/Olist/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;

-- insert into sellers table
COPY raw.sellers
FROM 'C:/Olist/olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;

-- insert into product_category_name_translation table
COPY raw.product_category_name_translation
FROM 'C:/Olist/product_category_name_translation.csv'
DELIMITER ','
CSV HEADER;



-- check for table content

SELECT * FROM raw.customers;

SELECT * FROM raw.geolocation;

SELECT * FROM raw.order_items;

SELECT * FROM raw.order_payments;

SELECT * FROM raw.order_reviews;

SELECT * FROM raw.orders;

SELECT * FROM raw.products;

SELECT * FROM raw.sellers;

SELECT * FROM raw.product_category_name_translation;




-- Number of rows in each table
SELECT 'customers', COUNT(*) FROM raw.customers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM raw.geolocation
UNION ALL
SELECT 'order_items', COUNT(*) FROM raw.order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM raw.order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM raw.order_reviews
UNION ALL
SELECT 'orders', COUNT(*) FROM raw.orders
UNION ALL
SELECT 'sellers', COUNT(*) FROM raw.sellers
UNION ALL
SELECT 'products', COUNT(*) FROM raw.products
UNION ALL
SELECT 'product_category_name_translation', COUNT(*) FROM raw.product_category_name_translation




-- Number of Columns in each table
SELECT table_name, COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'raw'
GROUP BY table_name
ORDER BY column_count DESC;


-- Check for duplicate order_id in orders table to define the grain 
SELECT review_id, order_id, COUNT(*) AS review_count
FROM raw.order_reviews 
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS order_count
FROM raw.orders
GROUP BY order_id
HAVING COUNT(*) > 1;