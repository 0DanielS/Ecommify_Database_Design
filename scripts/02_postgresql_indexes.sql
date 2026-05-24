-- Indices iniciales sugeridos para el modulo transaccional en PostgreSQL.

SET search_path TO ecommify, public;

CREATE INDEX IF NOT EXISTS idx_customers_unique_id
    ON customers(customer_unique_id);

CREATE INDEX IF NOT EXISTS idx_customers_state_city
    ON customers(customer_state, customer_city);

CREATE INDEX IF NOT EXISTS idx_sellers_state_city
    ON sellers(seller_state, seller_city);

CREATE INDEX IF NOT EXISTS idx_products_category_name
    ON products(product_category_name);

CREATE INDEX IF NOT EXISTS idx_orders_customer_id
    ON orders(customer_id);

CREATE INDEX IF NOT EXISTS idx_orders_status
    ON orders(order_status);

CREATE INDEX IF NOT EXISTS idx_orders_purchase_timestamp
    ON orders(order_purchase_timestamp);

CREATE INDEX IF NOT EXISTS idx_orders_customer_purchase
    ON orders(customer_id, order_purchase_timestamp);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id
    ON order_items(order_id);

CREATE INDEX IF NOT EXISTS idx_order_items_product_id
    ON order_items(product_id);

CREATE INDEX IF NOT EXISTS idx_order_items_seller_id
    ON order_items(seller_id);

CREATE INDEX IF NOT EXISTS idx_order_items_product_seller
    ON order_items(product_id, seller_id);

CREATE INDEX IF NOT EXISTS idx_order_items_order_product
    ON order_items(order_id, product_id);

CREATE INDEX IF NOT EXISTS idx_order_payments_order_id
    ON order_payments(order_id);

CREATE INDEX IF NOT EXISTS idx_order_payments_type
    ON order_payments(payment_type);

CREATE INDEX IF NOT EXISTS idx_order_reviews_order_id
    ON order_reviews(order_id);

CREATE INDEX IF NOT EXISTS idx_order_reviews_score
    ON order_reviews(review_score);

CREATE INDEX IF NOT EXISTS idx_geolocation_state_city
    ON geolocation_reference(geolocation_state, geolocation_city);