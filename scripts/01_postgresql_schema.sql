-- DDL preliminar para el modulo transaccional en PostgreSQL.
-- El esquema privilegia 3FN para el nucleo operacional.

BEGIN;

CREATE SCHEMA IF NOT EXISTS ecommify;
SET search_path TO ecommify, public;

CREATE TABLE IF NOT EXISTS geolocation_reference (
    zip_code_prefix INTEGER PRIMARY KEY,
    geolocation_city VARCHAR(120) NOT NULL,
    geolocation_state CHAR(2) NOT NULL,
    geolocation_lat NUMERIC(10, 6),
    geolocation_lng NUMERIC(10, 6),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_geolocation_state_length CHECK (char_length(geolocation_state) = 2)
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(120) NOT NULL,
    customer_state CHAR(2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_customers_geolocation
        FOREIGN KEY (customer_zip_code_prefix)
        REFERENCES geolocation_reference(zip_code_prefix),
    CONSTRAINT chk_customers_state_length CHECK (char_length(customer_state) = 2)
);

CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(120) NOT NULL,
    seller_state CHAR(2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_sellers_geolocation
        FOREIGN KEY (seller_zip_code_prefix)
        REFERENCES geolocation_reference(zip_code_prefix),
    CONSTRAINT chk_sellers_state_length CHECK (char_length(seller_state) = 2)
);

CREATE TABLE IF NOT EXISTS category_translation (
    product_category_name VARCHAR(120) PRIMARY KEY,
    product_category_name_english VARCHAR(120) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(120),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g NUMERIC(10, 2),
    product_length_cm NUMERIC(10, 2),
    product_height_cm NUMERIC(10, 2),
    product_width_cm NUMERIC(10, 2),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_products_category
        FOREIGN KEY (product_category_name)
        REFERENCES category_translation(product_category_name),
    CONSTRAINT chk_products_name_length CHECK (product_name_length IS NULL OR product_name_length >= 0),
    CONSTRAINT chk_products_description_length CHECK (product_description_length IS NULL OR product_description_length >= 0),
    CONSTRAINT chk_products_photos_qty CHECK (product_photos_qty IS NULL OR product_photos_qty >= 0),
    CONSTRAINT chk_products_weight CHECK (product_weight_g IS NULL OR product_weight_g >= 0),
    CONSTRAINT chk_products_length CHECK (product_length_cm IS NULL OR product_length_cm >= 0),
    CONSTRAINT chk_products_height CHECK (product_height_cm IS NULL OR product_height_cm >= 0),
    CONSTRAINT chk_products_width CHECK (product_width_cm IS NULL OR product_width_cm >= 0)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_purchase_timestamp TIMESTAMP NOT NULL,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    CONSTRAINT chk_orders_status
        CHECK (order_status IN ('created', 'approved', 'invoiced', 'processing', 'shipped', 'delivered', 'unavailable', 'canceled'))
);

CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(32) NOT NULL,
    order_item_id SMALLINT NOT NULL,
    product_id VARCHAR(32) NOT NULL,
    seller_id VARCHAR(32) NOT NULL,
    shipping_limit_date TIMESTAMP NOT NULL,
    price NUMERIC(12, 2) NOT NULL,
    freight_value NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),
    CONSTRAINT fk_order_items_seller
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id),
    CONSTRAINT chk_order_items_price CHECK (price >= 0),
    CONSTRAINT chk_order_items_freight CHECK (freight_value >= 0)
);

CREATE TABLE IF NOT EXISTS order_payments (
    order_id VARCHAR(32) NOT NULL,
    payment_sequential SMALLINT NOT NULL,
    payment_type VARCHAR(20) NOT NULL,
    payment_installments SMALLINT NOT NULL,
    payment_value NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_order_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT chk_order_payments_installments CHECK (payment_installments >= 0),
    CONSTRAINT chk_order_payments_value CHECK (payment_value >= 0)
);

CREATE TABLE IF NOT EXISTS order_reviews (
    review_id VARCHAR(32) PRIMARY KEY,
    order_id VARCHAR(32) NOT NULL,
    review_score SMALLINT NOT NULL,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATE NOT NULL,
    review_answer_timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_order_reviews_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT chk_order_reviews_score CHECK (review_score BETWEEN 1 AND 5)
);

COMMIT;