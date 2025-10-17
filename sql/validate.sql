-- Базовая проверка каунтов
SET search_path TO student51;

SELECT 'stg_sample_superstore' AS table_name, COUNT(*) AS row_count FROM student51.stg_sample_superstore
UNION ALL
SELECT 'hub_customer', COUNT(*) FROM student51.hub_customer
UNION ALL
SELECT 'hub_product', COUNT(*) FROM student51.hub_product
UNION ALL
SELECT 'hub_location', COUNT(*) FROM student51.hub_location
UNION ALL
SELECT 'hub_order', COUNT(*) FROM student51.hub_order
UNION ALL
SELECT 'l_order_customer', COUNT(*) FROM student51.l_order_customer
UNION ALL
SELECT 'l_order_product', COUNT(*) FROM student51.l_order_product
UNION ALL
SELECT 'l_order_location', COUNT(*) FROM student51.l_order_location
UNION ALL
SELECT 's_customer_attr', COUNT(*) FROM student51.s_customer_attr
UNION ALL
SELECT 's_product_attr', COUNT(*) FROM student51.s_product_attr
UNION ALL
SELECT 's_location_attr', COUNT(*) FROM student51.s_location_attr
UNION ALL
SELECT 's_order_metrics', COUNT(*) FROM student51.s_order_metrics
ORDER BY table_name;

