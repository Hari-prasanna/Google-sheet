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