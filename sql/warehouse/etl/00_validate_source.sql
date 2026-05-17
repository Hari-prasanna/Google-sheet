-- Pre-load referential integrity check: must return 0 rows
SELECT ol.order_id, ol.line_no
FROM order_lines ol
LEFT JOIN orders o ON o.order_id = ol.order_id
WHERE o.order_id IS NULL;