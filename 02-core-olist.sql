-- Check database
SELECT current_database();


-- Create core OList tables

-- create orders_payments fact table (with foreign key to orders)
-- Grain: one row per payment for an order, with details about the payment type and value.
CREATE TABLE core.fact_order_payments (
    order_id TEXT NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type TEXT NOT NULL,
    payment_installments INT NOT NULL,
    payment_value NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES core.fact_orders(order_id)
);

-- create order_items fact table (with foreign keys to products and sellers)
-- Grain: one row per order item, with details about the product and seller.
CREATE TABLE core.fact_order_items (
    order_id TEXT NOT NULL,
    order_item_id TEXT NOT NULL,
    product_id TEXT REFERENCES core.dim_products(product_id),
    seller_id TEXT REFERENCES core.dim_sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2) NOT NULL,
    freight_value NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES core.fact_orders(order_id)
);



-- create orders fact table (with foreign key to customers)
-- Grain: one row per order, with details about the order status and timestamps.
CREATE TABLE core.fact_orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES core.dim_customers(customer_id),
    order_status TEXT NOT NULL,
    order_purchase_timestamp TIMESTAMP NOT NULL,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- create order_reviews fact table (with foreign key to orders)
CREATE TABLE core.fact_order_reviews (
    review_id TEXT,
    order_id TEXT,
    review_score NUMERIC(2, 1) NOT NULL,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    PRIMARY KEY (review_id, order_id),
    FOREIGN KEY (order_id) REFERENCES core.fact_orders(order_id)
);

-- Alter review score column to integer type
ALTER TABLE core.fact_order_reviews
ALTER COLUMN review_score TYPE INTEGER
USING review_score::INTEGER;

-- check the data type of the altered column
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_schema = 'core'
AND table_name = 'fact_order_reviews'
AND column_name = 'review_score';


-- create customers  dim table 
CREATE TABLE core.dim_customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix VARCHAR(10),
    customer_city TEXT,
    customer_state TEXT
);


SELECT * FROM core.dim_customers

-- create geolocation dim table
CREATE TABLE core.dim_geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat NUMERIC(9, 6),
    geolocation_lng NUMERIC(9, 6),
    geolocation_city TEXT,
    geolocation_state TEXT
);


-- create products dim table
CREATE TABLE core.dim_products (
    product_id TEXT PRIMARY KEY, 
    product_category_name TEXT, 
    product_name_lenght INT, 
    product_description_lenght INT, 
    product_photos_qty INT, 
    product_weight_g INT, 
    product_length_cm NUMERIC(6, 2), 
    product_height_cm NUMERIC(6, 2), 
    product_width_cm NUMERIC(6, 2)
);

-- create sellers dim table
CREATE TABLE core.dim_sellers(
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10), 
    seller_city TEXT, 
    seller_state TEXT
)

-- create product_category_name dim table
CREATE TABLE core.dim_product_category_name_translation(
    product_category_name TEXT PRIMARY KEY, 
    product_category_name_english TEXT
)

SELECT * FROM core.fact_order_items

SELECT * FROM core.fact_order_payments

SELECT * FROM core.fact_orders

SELECT * FROM core.fact_order_reviews

SELECT * FROM core.dim_customers

SELECT * FROM core.dim_geolocation

SELECT * FROM core.dim_products

SELECT * FROM core.dim_sellers

SELECT * FROM core.dim_product_category_name_translation

-- Insert data into core tables from raw tables
INSERT INTO core.dim_customers (customer_id, customer_unique_id,
             customer_zip_code_prefix, customer_city, customer_state)
SELECT customer_id, customer_unique_id, customer_zip_code_prefix, 
            customer_city, customer_state
FROM raw.customers;

--- Insert into geolocation dim table
INSERT INTO core.dim_geolocation (geolocation_zip_code_prefix, 
            geolocation_lat, geolocation_lng, 
        geolocation_city, geolocation_state)
SELECT geolocation_zip_code_prefix, 
        NULLIF(geolocation_lat, '')::NUMERIC(9, 6),
        NULLIF(geolocation_lng, '')::NUMERIC(9, 6),
         geolocation_city, geolocation_state
FROM raw.geolocation;

-- Insert into products dim table
INSERT INTO core.dim_products (product_id, product_category_name,
             product_name_lenght, product_description_lenght, 
             product_photos_qty, product_weight_g, 
             product_length_cm, product_height_cm, product_width_cm)
SELECT product_id, product_category_name,
        NULLIF(product_name_lenght, '')::INT,
        NULLIF(product_description_lenght, '')::INT,
        NULLIF(product_photos_qty, '')::INT,
        NULLIF(product_weight_g, '')::INT,
        NULLIF(product_length_cm, '')::NUMERIC(6, 2),
        NULLIF(product_height_cm, '')::NUMERIC(6, 2),
        NULLIF(product_width_cm, '')::NUMERIC(6, 2)
FROM raw.products;

-- Insert into sellers dim table
INSERT INTO core.dim_sellers (seller_id, seller_zip_code_prefix,
             seller_city, seller_state)
SELECT seller_id, seller_zip_code_prefix,
        seller_city, seller_state
FROM raw.sellers;

-- Insert into product_category_name dim table
INSERT INTO core.dim_product_category_name_translation (product_category_name, 
            product_category_name_english)
SELECT product_category_name, 
        product_category_name_english
FROM raw.product_category_name_translation; 

-- Insert into orders fact table
INSERT INTO core.fact_orders (order_id, customer_id, order_status,
             order_purchase_timestamp, order_approved_at, 
             order_delivered_carrier_date, order_delivered_customer_date, 
             order_estimated_delivery_date)
SELECT order_id, customer_id, order_status,
        NULLIF(order_purchase_timestamp, '')::TIMESTAMP,
        NULLIF(order_approved_at, '')::TIMESTAMP,
        NULLIF(order_delivered_carrier_date, '')::TIMESTAMP,
        NULLIF(order_delivered_customer_date, '')::TIMESTAMP,
        NULLIF(order_estimated_delivery_date, '')::TIMESTAMP
FROM raw.orders;

-- Insert into order_items fact table
INSERT INTO core.fact_order_items (order_id, order_item_id, product_id, seller_id,
             shipping_limit_date, price, freight_value)
SELECT order_id, order_item_id, product_id, seller_id,
        NULLIF(shipping_limit_date, '')::TIMESTAMP,
        NULLIF(price, '')::NUMERIC(10, 2),
        NULLIF(freight_value, '')::NUMERIC(10, 2)
FROM raw.order_items;

-- Insert into order_payments fact table
INSERT INTO core.fact_order_payments (order_id, payment_sequential, payment_type,
             payment_installments, payment_value)
SELECT order_id, NULLIF(payment_sequential, '')::INT, payment_type,
        NULLIF(payment_installments, '')::INT,
        NULLIF(payment_value, '')::NUMERIC(10, 2)
FROM raw.order_payments;

-- Insert into order_reviews fact table
INSERT INTO core.fact_order_reviews (review_id, order_id, review_score,
             review_comment_title, review_comment_message, review_creation_date,
             review_answer_timestamp)
SELECT review_id, order_id, NULLIF(review_score, '')::NUMERIC(2, 1),
        review_comment_title, review_comment_message,
        NULLIF(review_creation_date, '')::TIMESTAMP,
        NULLIF(review_answer_timestamp, '')::TIMESTAMP
FROM raw.order_reviews;

-- confirm that the data was inserted correctly by checking the first few rows of each table
SELECT * FROM core.fact_orders;
SELECT * FROM core.fact_order_items;
SELECT * FROM core.fact_order_payments; 
SELECT * FROM core.fact_order_reviews;
SELECT * FROM core.dim_customers;
SELECT * FROM core.dim_geolocation; 
SELECT * FROM core.dim_products;
SELECT * FROM core.dim_sellers; 
SELECT * FROM core.dim_product_category_name_translation;


