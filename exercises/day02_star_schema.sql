-- ============================================================
-- DAY 2: Building the Star Schema (DDL)
--
-- Source schema (Day 0) had 9 tables in 3NF. The star schema
-- collapses them to 5 tables, organized around the order-line
-- measurement event:
--
--   1 fact table    (fact_order_lines)
--   4 dimensions    (dim_date, dim_customer, dim_product, dim_salesperson)
--
-- Hierarchies in the source are flattened into the dimension
-- at the lowest grain:
--   - regions + territories  --> folded into dim_salesperson
--   - brands + categories    --> folded into dim_product
--   - orders header          --> dissolved (date_key from order_date,
--                                order_id kept on fact as degenerate dim)
-- ============================================================

DROP TABLE IF EXISTS fact_order_lines  CASCADE;
DROP TABLE IF EXISTS dim_date          CASCADE;
DROP TABLE IF EXISTS dim_customer      CASCADE;
DROP TABLE IF EXISTS dim_product       CASCADE;
DROP TABLE IF EXISTS dim_salesperson   CASCADE;

-- ============================================================
-- DIMENSION 1: dim_date
--
-- Grain: one row per calendar day.
-- Source: built from scratch (no source table for dates).
-- SCD: not applicable (a date never "changes").
-- Date keys are integer YYYYMMDD for human readability.
-- ============================================================

CREATE TABLE dim_date (
    date_key        INTEGER     PRIMARY KEY,        -- YYYYMMDD, e.g. 20250115
    full_date       DATE        NOT NULL UNIQUE,    -- the actual date
    day_of_month    SMALLINT    NOT NULL,           -- 1..31
    day_of_week     SMALLINT    NOT NULL,           -- 0=Sun .. 6=Sat
    day_name        VARCHAR(10) NOT NULL,           -- 'Monday' etc.
    month_number    SMALLINT    NOT NULL,           -- 1..12
    month_name      VARCHAR(10) NOT NULL,           -- 'January' etc.
    quarter         SMALLINT    NOT NULL,           -- 1..4
    year            SMALLINT    NOT NULL,           -- 2024, 2025...
    year_month      CHAR(7)     NOT NULL,           -- '2025-01' (sortable)
    year_quarter    CHAR(7)     NOT NULL,           -- '2025-Q1'
    is_weekend      BOOLEAN     NOT NULL
);

-- Populate dim_date for 2023-01-01 through 2026-12-31.
-- generate_series is a Postgres feature that creates a date range.
INSERT INTO dim_date (
    date_key, full_date, day_of_month, day_of_week, day_name,
    month_number, month_name, quarter, year, year_month, year_quarter, is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER          AS date_key,
    d                                        AS full_date,
    EXTRACT(DAY  FROM d)::SMALLINT           AS day_of_month,
    EXTRACT(DOW  FROM d)::SMALLINT           AS day_of_week,
    TRIM(TO_CHAR(d, 'Day'))                  AS day_name,
    EXTRACT(MONTH FROM d)::SMALLINT          AS month_number,
    TRIM(TO_CHAR(d, 'Month'))                AS month_name,
    EXTRACT(QUARTER FROM d)::SMALLINT        AS quarter,
    EXTRACT(YEAR  FROM d)::SMALLINT          AS year,
    TO_CHAR(d, 'YYYY-MM')                    AS year_month,
    TO_CHAR(d, 'YYYY"-Q"Q')                  AS year_quarter,
    EXTRACT(DOW FROM d) IN (0, 6)            AS is_weekend
FROM generate_series(DATE '2023-01-01', DATE '2026-12-31', INTERVAL '1 day') AS d;

-- ============================================================
-- DIMENSION 2: dim_customer
--
-- Grain: one row per customer per state-of-being.
-- Source: customers
-- SCD: Type 2-ready (effective dates, current flag).
--      Today we load with all customers as "current" rows.
--      Day 4 will demonstrate adding a new row when ABC moves.
-- ============================================================

CREATE TABLE dim_customer (
    customer_key        SERIAL          PRIMARY KEY,    -- surrogate
    customer_id         INTEGER         NOT NULL,       -- natural key from source
    customer_name       VARCHAR(100)    NOT NULL,
    headquarters_state  VARCHAR(2),
    billing_address     VARCHAR(200),
    billing_city        VARCHAR(100),
    billing_state       VARCHAR(2),
    billing_zip         VARCHAR(10),
    sic_code            VARCHAR(10),
    industry_name       VARCHAR(100),
    -- SCD Type 2 housekeeping:
    effective_date      DATE            NOT NULL DEFAULT DATE '1900-01-01',
    expiry_date         DATE            NOT NULL DEFAULT DATE '9999-12-31',
    is_current          BOOLEAN         NOT NULL DEFAULT TRUE
);

-- Index for lookup joins during ETL
CREATE INDEX idx_dim_customer_natural ON dim_customer (customer_id, is_current);

-- Mandatory "Unknown" row so fact tables never need NULL FKs.
-- Convention: customer_key = -1 means "we know a fact happened but
-- we don't know which customer it belonged to."
INSERT INTO dim_customer (customer_key, customer_id, customer_name, is_current)
OVERRIDING SYSTEM VALUE
VALUES (-1, -1, 'Unknown', TRUE);

-- Initial load: every customer from the source becomes a current row.
INSERT INTO dim_customer (
    customer_id, customer_name, headquarters_state,
    billing_address, billing_city, billing_state, billing_zip,
    sic_code, industry_name,
    effective_date, expiry_date, is_current
)
SELECT
    customer_id, customer_name, headquarters_state,
    billing_address, billing_city, billing_state, billing_zip,
    sic_code, industry_name,
    DATE '1900-01-01', DATE '9999-12-31', TRUE
FROM customers;

-- ============================================================
-- DIMENSION 3: dim_product
--
-- Grain: one row per SKU per state-of-being.
-- Source: products + brands + categories (flattened).
-- SCD: Type 2-ready.
-- Note: unit_price and unit_cost stay here as attributes for
-- reference, but the ACTUAL pricing of a sale is captured in
-- the fact (extended_price), so historical orders don't re-price
-- themselves when product prices change.
-- ============================================================

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

INSERT INTO dim_product (product_key, sku, product_name, brand_code, brand_name,
                          brand_manager, category_code, category_name,
                          unit_price, unit_cost, is_current)
OVERRIDING SYSTEM VALUE
VALUES (-1, 'UNKNOWN', 'Unknown', 'UNK', 'Unknown', 'Unknown', 'UNK', 'Unknown',
        0, 0, TRUE);

INSERT INTO dim_product (
    sku, product_name, product_description,
    brand_code, brand_name, brand_manager,
    category_code, category_name,
    unit_price, unit_cost,
    effective_date, expiry_date, is_current
)
SELECT
    p.sku, p.product_name, p.product_description,
    b.brand_code, b.brand_name, b.brand_manager,
    c.category_code, c.category_name,
    p.unit_price, p.unit_cost,
    DATE '1900-01-01', DATE '9999-12-31', TRUE
FROM products  p
JOIN brands    b ON b.brand_code    = p.brand_code
JOIN categories c ON c.category_code = p.category_code;

-- ============================================================
-- DIMENSION 4: dim_salesperson
--
-- Grain: one row per salesperson per state-of-being.
-- Source: salespeople + territories + regions (flattened).
-- SCD: Type 2-ready (e.g. when a rep moves territory).
-- ============================================================

CREATE TABLE dim_salesperson (
    salesperson_key     SERIAL          PRIMARY KEY,
    salesperson_id      INTEGER         NOT NULL,
    salesperson_name    VARCHAR(100)    NOT NULL,
    -- Territory (flattened):
    territory_code      VARCHAR(10)     NOT NULL,
    territory_name      VARCHAR(50)     NOT NULL,
    territory_manager   VARCHAR(100)    NOT NULL,
    -- Region (flattened):
    region_code         VARCHAR(10)     NOT NULL,
    region_name         VARCHAR(50)     NOT NULL,
    region_vp           VARCHAR(100)    NOT NULL,
    -- SCD Type 2 housekeeping:
    effective_date      DATE            NOT NULL DEFAULT DATE '1900-01-01',
    expiry_date         DATE            NOT NULL DEFAULT DATE '9999-12-31',
    is_current          BOOLEAN         NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_dim_salesperson_natural ON dim_salesperson (salesperson_id, is_current);

INSERT INTO dim_salesperson (salesperson_key, salesperson_id, salesperson_name,
                              territory_code, territory_name, territory_manager,
                              region_code, region_name, region_vp, is_current)
OVERRIDING SYSTEM VALUE
VALUES (-1, -1, 'Unknown',
        'UNK', 'Unknown', 'Unknown',
        'UNK', 'Unknown', 'Unknown',
        TRUE);

INSERT INTO dim_salesperson (
    salesperson_id, salesperson_name,
    territory_code, territory_name, territory_manager,
    region_code, region_name, region_vp,
    effective_date, expiry_date, is_current
)
SELECT
    s.salesperson_id, s.salesperson_name,
    t.territory_code, t.territory_name, t.territory_manager,
    r.region_code, r.region_name, r.region_vp,
    DATE '1900-01-01', DATE '9999-12-31', TRUE
FROM salespeople s
JOIN territories t ON t.territory_code = s.territory_code
JOIN regions     r ON r.region_code    = t.region_code;

-- ============================================================
-- FACT TABLE: fact_order_lines
--
-- GRAIN: one row per order line (one product on one order
--        on one date placed by one customer to one salesperson).
--
-- Foreign keys: surrogate keys to all four dimensions.
-- Degenerate dimensions: order_id, line_no (kept on the fact).
-- Facts: quantity, extended_price, extended_cost, margin_dollars.
--
-- All four facts are FULLY ADDITIVE -- can be summed across
-- any combination of dimensions.
-- ============================================================

CREATE TABLE fact_order_lines (
    -- Surrogate FKs to dimensions:
    date_key            INTEGER         NOT NULL REFERENCES dim_date(date_key),
    customer_key        INTEGER         NOT NULL REFERENCES dim_customer(customer_key),
    salesperson_key     INTEGER         NOT NULL REFERENCES dim_salesperson(salesperson_key),
    product_key         INTEGER         NOT NULL REFERENCES dim_product(product_key),

    -- Degenerate dimensions:
    order_id            INTEGER         NOT NULL,
    line_no             INTEGER         NOT NULL,

    -- Facts:
    quantity            INTEGER         NOT NULL,
    extended_price      NUMERIC(12,2)   NOT NULL,    -- quantity * unit_price
    extended_cost       NUMERIC(12,2)   NOT NULL,    -- quantity * unit_cost
    margin_dollars      NUMERIC(12,2)   NOT NULL,    -- extended_price - extended_cost

    PRIMARY KEY (order_id, line_no)
);

CREATE INDEX idx_fact_date     ON fact_order_lines (date_key);
CREATE INDEX idx_fact_customer ON fact_order_lines (customer_key);
CREATE INDEX idx_fact_product  ON fact_order_lines (product_key);
CREATE INDEX idx_fact_sp       ON fact_order_lines (salesperson_key);

-- ============================================================
-- LOAD THE FACT TABLE (Day 3 preview, but worth doing now
-- so we can verify the model end-to-end).
--
-- This is the "lookup join" pattern in action: every natural
-- key from the source is translated into a surrogate key by
-- joining to the corresponding dimension.
-- ============================================================

INSERT INTO fact_order_lines (
    date_key, customer_key, salesperson_key, product_key,
    order_id, line_no,
    quantity, extended_price, extended_cost, margin_dollars
)
SELECT
    dd.date_key,                                       
    COALESCE(dc.customer_key, -1) AS customer_key,
    COALESCE(ds.salesperson_key, -1) AS salesperson_key,
    COALESCE(dp.product_key, -1) AS product_key,
    ol.order_id,
    ol.line_no,
    ol.quantity,
    ol.quantity *  COALESCE(dp.unit_price, 0) AS extended_price,
    ol.quantity *  COALESCE(dp.unit_cost,  0) AS extended_cost,
    ol.quantity * (COALESCE(dp.unit_price, 0) - COALESCE(dp.unit_cost,  0)) AS margin_dollars
FROM order_lines ol
JOIN orders o ON o.order_id = ol.order_id 
JOIN dim_date dd ON dd.full_date = o.order_date
LEFT JOIN dim_customer dc 
ON dc.customer_id = o.customer_id
AND o.order_date BETWEEN dc.effective_date AND dc.expiry_date
LEFT JOIN dim_salesperson ds 
ON ds.salesperson_id = o.salesperson_id
AND o.order_date BETWEEN ds.effective_date AND ds.expiry_date
LEFT JOIN dim_product dp 
ON dp.sku = ol.sku
AND o.order_date BETWEEN dp.effective_date AND dp.expiry_date;

-- ============================================================
-- Smoke tests
-- ============================================================

SELECT 'dim_date'        AS table_name, COUNT(*) AS row_count FROM dim_date
UNION ALL SELECT 'dim_customer',    COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_product',     COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_salesperson', COUNT(*) FROM dim_salesperson
UNION ALL SELECT 'fact_order_lines', COUNT(*) FROM fact_order_lines
ORDER BY table_name;

