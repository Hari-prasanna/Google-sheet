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
