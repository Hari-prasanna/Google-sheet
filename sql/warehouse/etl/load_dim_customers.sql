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