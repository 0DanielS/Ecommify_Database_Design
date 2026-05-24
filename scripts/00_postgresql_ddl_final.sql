-- DDL final consolidado para PostgreSQL
-- Proyecto: Ecommify / Olist
-- Objetivo: modelo transaccional en 3FN para el nucleo operacional

BEGIN;

CREATE SCHEMA IF NOT EXISTS ecommify;
SET search_path TO ecommify, public;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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
        REFERENCES geolocation_reference(zip_code_prefix)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
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
        REFERENCES geolocation_reference(zip_code_prefix)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
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
        REFERENCES category_translation(product_category_name)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
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
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_orders_status
        CHECK (order_status IN ('created', 'approved', 'invoiced', 'processing', 'shipped', 'delivered', 'unavailable', 'canceled')),
    CONSTRAINT chk_orders_date_sequence
        CHECK (
            order_approved_at IS NULL OR order_approved_at >= order_purchase_timestamp
        )
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
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_seller
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
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
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
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
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT chk_order_reviews_score CHECK (review_score BETWEEN 1 AND 5),
    CONSTRAINT chk_order_reviews_answer_after_creation CHECK (review_answer_timestamp >= review_creation_date)
);

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

DROP TRIGGER IF EXISTS trg_geolocation_reference_updated_at ON geolocation_reference;
CREATE TRIGGER trg_geolocation_reference_updated_at
BEFORE UPDATE ON geolocation_reference
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_customers_updated_at ON customers;
CREATE TRIGGER trg_customers_updated_at
BEFORE UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_sellers_updated_at ON sellers;
CREATE TRIGGER trg_sellers_updated_at
BEFORE UPDATE ON sellers
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_category_translation_updated_at ON category_translation;
CREATE TRIGGER trg_category_translation_updated_at
BEFORE UPDATE ON category_translation
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_products_updated_at ON products;
CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_orders_updated_at ON orders;
CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_order_items_updated_at ON order_items;
CREATE TRIGGER trg_order_items_updated_at
BEFORE UPDATE ON order_items
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_order_payments_updated_at ON order_payments;
CREATE TRIGGER trg_order_payments_updated_at
BEFORE UPDATE ON order_payments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_order_reviews_updated_at ON order_reviews;
CREATE TRIGGER trg_order_reviews_updated_at
BEFORE UPDATE ON order_reviews
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

COMMENT ON SCHEMA ecommify IS 'Esquema transaccional normalizado del proyecto Ecommify/Olist.';

COMMENT ON TABLE geolocation_reference IS 'Dimension geografica depurada por zip_code_prefix para clientes y vendedores.';
COMMENT ON TABLE customers IS 'Clientes del marketplace.';
COMMENT ON TABLE sellers IS 'Vendedores registrados en la plataforma.';
COMMENT ON TABLE category_translation IS 'Traduccion de categorias de producto de portugues a ingles.';
COMMENT ON TABLE products IS 'Catalogo maestro de productos.';
COMMENT ON TABLE orders IS 'Cabecera transaccional de ordenes.';
COMMENT ON TABLE order_items IS 'Detalle de lineas por orden.';
COMMENT ON TABLE order_payments IS 'Eventos de pago asociados a una orden.';
COMMENT ON TABLE order_reviews IS 'Resenas emitidas por clientes sobre una orden.';

COMMENT ON COLUMN customers.customer_unique_id IS 'Identificador de cliente de negocio; no es PK porque un customer_unique_id puede aparecer en multiples customer_id.';
COMMENT ON COLUMN orders.order_status IS 'Estado operacional de la orden segun el dataset Olist.';
COMMENT ON COLUMN order_items.order_item_id IS 'Secuencia del item dentro de una orden.';
COMMENT ON COLUMN order_payments.payment_sequential IS 'Secuencia del pago dentro de una orden.';
COMMENT ON COLUMN order_reviews.review_score IS 'Calificacion de satisfaccion en escala de 1 a 5.';

COMMIT;