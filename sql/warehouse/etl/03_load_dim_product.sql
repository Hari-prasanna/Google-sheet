INSERT INTO dim_product (product_key, sku, product_name, brand_code, brand_name,
                          brand_manager, category_code, category_name,
                          unit_price, unit_cost, is_current)
OVERRIDING SYSTEM VALUE
VALUES (-1, 'UNKNOWN', 'Unknown', 'UNK', 'Unknown', 'Unknown', 'UNK', 'Unknown',
        0, 0, TRUE)
ON CONFLICT (product_key) DO NOTHING; -- prevents the duplication flag for -1 product_key

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
JOIN categories c ON c.category_code = p.category_code
WHERE NOT EXISTS(SELECT 1 FROM dim_product dp 
					WHERE dp.sku = p.sku AND dp.is_current = TRUE); -- correlated subquery used for idempotent pattern
