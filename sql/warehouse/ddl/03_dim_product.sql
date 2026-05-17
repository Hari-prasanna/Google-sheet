CREATE TABLE dim_product (
    product_key         SERIAL          PRIMARY KEY,    -- surrogate
    sku                 VARCHAR(20)     NOT NULL,       -- natural key
    product_name        VARCHAR(100)    NOT NULL,
    product_description VARCHAR(500),
    -- Brand attributes (flattened from brands table):
    brand_code          VARCHAR(10)     NOT NULL,
    brand_name          VARCHAR(50)     NOT NULL,
    brand_manager       VARCHAR(100)    NOT NULL,
    -- Category attributes (flattened from categories table):
    category_code       VARCHAR(10)     NOT NULL,
    category_name       VARCHAR(50)     NOT NULL,
    -- Current-snapshot pricing (for reference / current-state reports):
    unit_price          NUMERIC(10,2)   NOT NULL,
    unit_cost           NUMERIC(10,2)   NOT NULL,
    -- SCD Type 2 housekeeping:
    effective_date      DATE            NOT NULL DEFAULT DATE '1900-01-01',
    expiry_date         DATE            NOT NULL DEFAULT DATE '9999-12-31',
    is_current          BOOLEAN         NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_dim_product_natural ON dim_product (sku, is_current);
