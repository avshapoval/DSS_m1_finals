-- Загрузка данных из staging в Data Vault
SET search_path TO student51;

-- Создаем временную таблицу с хешами
DROP TABLE IF EXISTS tmp_hashed;
CREATE TEMP TABLE tmp_hashed AS
SELECT
    ship_mode, segment, country, city, state,
    COALESCE(postal_code, '') AS postal_code,
    region, category, sub_category,
    sales, quantity, discount, profit,
    UPPER(TRIM(COALESCE(segment,'')))||'|'||UPPER(TRIM(COALESCE(country,'')))||'|'||UPPER(TRIM(COALESCE(state,'')))||'|'||UPPER(TRIM(COALESCE(city,'')))||'|'||UPPER(TRIM(COALESCE(postal_code,''))) AS bk_customer,
    UPPER(TRIM(COALESCE(category,'')))||'|'||UPPER(TRIM(COALESCE(sub_category,''))) AS bk_product,
    UPPER(TRIM(COALESCE(country,'')))||'|'||UPPER(TRIM(COALESCE(state,'')))||'|'||UPPER(TRIM(COALESCE(city,'')))||'|'||UPPER(TRIM(COALESCE(postal_code,'')))||'|'||UPPER(TRIM(COALESCE(region,''))) AS bk_location,
    UPPER(TRIM(COALESCE(ship_mode,'')))||'|'||UPPER(TRIM(COALESCE(segment,'')))||'|'||UPPER(TRIM(COALESCE(country,'')))||'|'||UPPER(TRIM(COALESCE(state,'')))||'|'||UPPER(TRIM(COALESCE(city,'')))||'|'||UPPER(TRIM(COALESCE(postal_code,'')))||'|'||UPPER(TRIM(COALESCE(region,'')))||'|'||UPPER(TRIM(COALESCE(category,'')))||'|'||UPPER(TRIM(COALESCE(sub_category,''))) AS bk_order,
    decode(md5(UPPER(TRIM(COALESCE(segment,'')))||'|'||UPPER(TRIM(COALESCE(country,'')))||'|'||UPPER(TRIM(COALESCE(state,'')))||'|'||UPPER(TRIM(COALESCE(city,'')))||'|'||UPPER(TRIM(COALESCE(postal_code,'')))), 'hex')::bytea AS customer_hkey,
    decode(md5(UPPER(TRIM(COALESCE(category,'')))||'|'||UPPER(TRIM(COALESCE(sub_category,'')))), 'hex')::bytea AS product_hkey,
    decode(md5(UPPER(TRIM(COALESCE(country,'')))||'|'||UPPER(TRIM(COALESCE(state,'')))||'|'||UPPER(TRIM(COALESCE(city,'')))||'|'||UPPER(TRIM(COALESCE(postal_code,'')))||'|'||UPPER(TRIM(COALESCE(region,'')))), 'hex')::bytea AS location_hkey,
    decode(md5(UPPER(TRIM(COALESCE(ship_mode,'')))||'|'||UPPER(TRIM(COALESCE(segment,'')))||'|'||UPPER(TRIM(COALESCE(country,'')))||'|'||UPPER(TRIM(COALESCE(state,'')))||'|'||UPPER(TRIM(COALESCE(city,'')))||'|'||UPPER(TRIM(COALESCE(postal_code,'')))||'|'||UPPER(TRIM(COALESCE(region,'')))||'|'||UPPER(TRIM(COALESCE(category,'')))||'|'||UPPER(TRIM(COALESCE(sub_category,'')))), 'hex')::bytea AS order_hkey
FROM student51.stg_sample_superstore;

-- Загрузка хабов
INSERT INTO student51.hub_customer (customer_hkey, bk_customer, load_dts, record_source)
SELECT DISTINCT h.customer_hkey, h.bk_customer, now(), 'SampleSuperstoreCSV'
FROM tmp_hashed h
LEFT JOIN student51.hub_customer c ON c.customer_hkey = h.customer_hkey
WHERE c.customer_hkey IS NULL;

INSERT INTO student51.hub_product (product_hkey, bk_product, load_dts, record_source)
SELECT DISTINCT h.product_hkey, h.bk_product, now(), 'SampleSuperstoreCSV'
FROM tmp_hashed h
LEFT JOIN student51.hub_product p ON p.product_hkey = h.product_hkey
WHERE p.product_hkey IS NULL;

INSERT INTO student51.hub_location (location_hkey, bk_location, load_dts, record_source)
SELECT DISTINCT h.location_hkey, h.bk_location, now(), 'SampleSuperstoreCSV'
FROM tmp_hashed h
LEFT JOIN student51.hub_location l ON l.location_hkey = h.location_hkey
WHERE l.location_hkey IS NULL;

INSERT INTO student51.hub_order (order_hkey, bk_order, load_dts, record_source)
SELECT DISTINCT h.order_hkey, h.bk_order, now(), 'SampleSuperstoreCSV'
FROM tmp_hashed h
LEFT JOIN student51.hub_order o ON o.order_hkey = h.order_hkey
WHERE o.order_hkey IS NULL;

-- Загрузка линков
INSERT INTO student51.l_order_location (l_order_location_hkey, order_hkey, location_hkey, load_dts, record_source)
SELECT DISTINCT decode(md5(encode(h.order_hkey,'hex')||'|'||encode(h.location_hkey,'hex')), 'hex')::bytea, h.order_hkey, h.location_hkey, now(), 'SampleSuperstoreCSV'
FROM tmp_hashed h
LEFT JOIN student51.l_order_location lol ON lol.order_hkey = h.order_hkey AND lol.location_hkey = h.location_hkey
WHERE lol.order_hkey IS NULL;

INSERT INTO student51.l_order_customer (l_order_customer_hkey, order_hkey, customer_hkey, load_dts, record_source)
SELECT DISTINCT decode(md5(encode(h.order_hkey,'hex')||'|'||encode(h.customer_hkey,'hex')), 'hex')::bytea, h.order_hkey, h.customer_hkey, now(), 'SampleSuperstoreCSV'
FROM tmp_hashed h
LEFT JOIN student51.l_order_customer loc ON loc.order_hkey = h.order_hkey AND loc.customer_hkey = h.customer_hkey
WHERE loc.order_hkey IS NULL;

INSERT INTO student51.l_order_product (l_order_product_hkey, order_hkey, product_hkey, load_dts, record_source)
SELECT DISTINCT decode(md5(encode(h.order_hkey,'hex')||'|'||encode(h.product_hkey,'hex')), 'hex')::bytea, h.order_hkey, h.product_hkey, now(), 'SampleSuperstoreCSV'
FROM tmp_hashed h
LEFT JOIN student51.l_order_product lop ON lop.order_hkey = h.order_hkey AND lop.product_hkey = h.product_hkey
WHERE lop.order_hkey IS NULL;

-- Загрузка спутников
INSERT INTO student51.s_customer_attr (customer_hkey, load_dts, record_source, segment, hashdiff)
SELECT DISTINCT ON (h.customer_hkey) h.customer_hkey, now(), 'SampleSuperstoreCSV', h.segment,
       decode(md5(UPPER(TRIM(COALESCE(h.segment,'')))), 'hex')::bytea
FROM tmp_hashed h;

INSERT INTO student51.s_product_attr (product_hkey, load_dts, record_source, category, sub_category, hashdiff)
SELECT DISTINCT ON (h.product_hkey) h.product_hkey, now(), 'SampleSuperstoreCSV', h.category, h.sub_category,
       decode(md5(UPPER(TRIM(COALESCE(h.category,'')))||'|'||UPPER(TRIM(COALESCE(h.sub_category,'')))), 'hex')::bytea
FROM tmp_hashed h;

INSERT INTO student51.s_location_attr (location_hkey, load_dts, record_source, country, state, city, postal_code, region, hashdiff)
SELECT DISTINCT ON (h.location_hkey) h.location_hkey, now(), 'SampleSuperstoreCSV', h.country, h.state, h.city, h.postal_code, h.region,
       decode(md5(UPPER(TRIM(COALESCE(h.country,'')))||'|'||UPPER(TRIM(COALESCE(h.state,'')))||'|'||UPPER(TRIM(COALESCE(h.city,'')))||'|'||UPPER(TRIM(COALESCE(h.postal_code,'')))||'|'||UPPER(TRIM(COALESCE(h.region,'')))), 'hex')::bytea
FROM tmp_hashed h;

INSERT INTO student51.s_order_metrics (order_hkey, load_dts, record_source, ship_mode, sales, quantity, discount, profit, hashdiff)
SELECT DISTINCT ON (h.order_hkey) h.order_hkey, now(), 'SampleSuperstoreCSV', h.ship_mode, h.sales, h.quantity, h.discount, h.profit,
       decode(md5(UPPER(TRIM(COALESCE(h.ship_mode,'')))||'|'||COALESCE(to_char(h.sales,'FM9999999990.9999'),'')||'|'||COALESCE(h.quantity::text,'')||'|'||COALESCE(to_char(h.discount,'FM999999990.9999'),'')||'|'||COALESCE(to_char(h.profit,'FM9999999990.9999'),'')), 'hex')::bytea
FROM tmp_hashed h;

DROP TABLE IF EXISTS tmp_hashed;
