-- What were the total order dollars by product category for January 2025?

SELECT 
	c.category_name,
	--p.product_name, 
	--ol.quantity,
	--p.unit_price,
	SUM(ol.quantity * p.unit_price) AS order_dollars
FROM order_lines ol 
JOIN orders o 
ON ol.order_id = o.order_id
JOIN products p 
ON ol.sku = p.sku 
JOIN categories c 
ON p.category_code = c.category_code 
WHERE o.order_date >= DATE '2025-01-01'
  AND o.order_date <  DATE '2025-02-01'
GROUP BY c.category_name