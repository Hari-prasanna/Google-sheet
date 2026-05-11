INSERT INTO fact_order_lines (
    date_key, customer_key, salesperson_key, product_key,
    order_id, line_no,
    quantity, extended_price, extended_cost, margin_dollars
)
SELECT
    dd.date_key,                                          
    COALESCE(dc.customer_key,    -1) AS customer_key,
    COALESCE(ds.salesperson_key, -1) AS salesperson_key,
    COALESCE(dp.product_key,     -1) AS product_key,
    ol.order_id,
    ol.line_no,
    ol.quantity AS quantity,
    ol.quantity *  COALESCE(dp.unit_price, 0) AS extended_price,
    ol.quantity *  COALESCE(dp.unit_cost,  0) AS extended_cost,
    ol.quantity * (COALESCE(dp.unit_price, 0) - COALESCE(dp.unit_cost,  0)) AS margin_dollars
FROM order_lines ol
LEFT JOIN orders o ON o.order_id = ol.order_id
LEFT JOIN dim_date dd ON dd.full_date = o.order_date
LEFT JOIN dim_customer dc 
ON dc.customer_id = o.customer_id
AND o.order_date BETWEEN dc.effective_date AND dc.expiry_date
LEFT JOIN dim_salesperson ds 
ON ds.salesperson_id = o.salesperson_id
AND o.order_date BETWEEN ds.effective_date AND ds.expiry_date
LEFT JOIN dim_product dp 
ON dp.sku = ol.sku
AND o.order_date BETWEEN dp.effective_date AND dp.expiry_date;