CREATE EXTENSION IF NOT EXISTS pgcrypto;
SET search_path TO student51;

-- Staging
DROP TABLE IF EXISTS student51.stg_sample_superstore CASCADE;
CREATE TABLE student51.stg_sample_superstore (
    ship_mode      text,
    segment        text,
    country        text,
    city           text,
    state          text,
    postal_code    text,
    region         text,
    category       text,
    sub_category   text,
    sales          numeric(18,4),
    quantity       integer,
    discount       numeric(9,4),
    profit         numeric(18,4)
) DISTRIBUTED RANDOMLY;

-- Hubs
DROP TABLE IF EXISTS student51.hub_customer CASCADE;
CREATE TABLE student51.hub_customer (
    customer_hkey      bytea PRIMARY KEY,
    bk_customer        text NOT NULL,
    load_dts           timestamp NOT NULL DEFAULT now(),
    record_source      text NOT NULL
) DISTRIBUTED BY (customer_hkey);

DROP TABLE IF EXISTS student51.hub_product CASCADE;
CREATE TABLE student51.hub_product (
    product_hkey       bytea PRIMARY KEY,
    bk_product         text NOT NULL,
    load_dts           timestamp NOT NULL DEFAULT now(),
    record_source      text NOT NULL
) DISTRIBUTED BY (product_hkey);

DROP TABLE IF EXISTS student51.hub_location CASCADE;
CREATE TABLE student51.hub_location (
    location_hkey      bytea PRIMARY KEY,
    bk_location        text NOT NULL,
    load_dts           timestamp NOT NULL DEFAULT now(),
    record_source      text NOT NULL
) DISTRIBUTED BY (location_hkey);

DROP TABLE IF EXISTS student51.hub_order CASCADE;
CREATE TABLE student51.hub_order (
    order_hkey         bytea PRIMARY KEY,
    bk_order           text NOT NULL,
    load_dts           timestamp NOT NULL DEFAULT now(),
    record_source      text NOT NULL
) DISTRIBUTED BY (order_hkey);

-- Links
DROP TABLE IF EXISTS student51.l_order_location CASCADE;
CREATE TABLE student51.l_order_location (
    l_order_location_hkey bytea NOT NULL,
    order_hkey            bytea NOT NULL,
    location_hkey         bytea NOT NULL,
    load_dts              timestamp NOT NULL DEFAULT now(),
    record_source         text NOT NULL,
    UNIQUE(order_hkey, location_hkey)
) DISTRIBUTED BY (order_hkey, location_hkey);

DROP TABLE IF EXISTS student51.l_order_customer CASCADE;
CREATE TABLE student51.l_order_customer (
    l_order_customer_hkey bytea NOT NULL,
    order_hkey            bytea NOT NULL,
    customer_hkey         bytea NOT NULL,
    load_dts              timestamp NOT NULL DEFAULT now(),
    record_source         text NOT NULL,
    UNIQUE(order_hkey, customer_hkey)
) DISTRIBUTED BY (order_hkey, customer_hkey);

DROP TABLE IF EXISTS student51.l_order_product CASCADE;
CREATE TABLE student51.l_order_product (
    l_order_product_hkey bytea NOT NULL,
    order_hkey           bytea NOT NULL,
    product_hkey         bytea NOT NULL,
    load_dts             timestamp NOT NULL DEFAULT now(),
    record_source        text NOT NULL,
    UNIQUE(order_hkey, product_hkey)
) DISTRIBUTED BY (order_hkey, product_hkey);

-- Satellites
DROP TABLE IF EXISTS student51.s_customer_attr CASCADE;
CREATE TABLE student51.s_customer_attr (
    customer_hkey   bytea NOT NULL,
    load_dts        timestamp NOT NULL DEFAULT now(),
    record_source   text NOT NULL,
    segment         text,
    hashdiff        bytea NOT NULL,
    PRIMARY KEY (customer_hkey, load_dts)
) DISTRIBUTED BY (customer_hkey);

DROP TABLE IF EXISTS student51.s_product_attr CASCADE;
CREATE TABLE student51.s_product_attr (
    product_hkey    bytea NOT NULL,
    load_dts        timestamp NOT NULL DEFAULT now(),
    record_source   text NOT NULL,
    category        text,
    sub_category    text,
    hashdiff        bytea NOT NULL,
    PRIMARY KEY (product_hkey, load_dts)
) DISTRIBUTED BY (product_hkey);

DROP TABLE IF EXISTS student51.s_location_attr CASCADE;
CREATE TABLE student51.s_location_attr (
    location_hkey   bytea NOT NULL,
    load_dts        timestamp NOT NULL DEFAULT now(),
    record_source   text NOT NULL,
    country         text,
    state           text,
    city            text,
    postal_code     text,
    region          text,
    hashdiff        bytea NOT NULL,
    PRIMARY KEY (location_hkey, load_dts)
) DISTRIBUTED BY (location_hkey);

DROP TABLE IF EXISTS student51.s_order_metrics CASCADE;
CREATE TABLE student51.s_order_metrics (
    order_hkey      bytea NOT NULL,
    load_dts        timestamp NOT NULL DEFAULT now(),
    record_source   text NOT NULL,
    ship_mode       text,
    sales           numeric(18,4),
    quantity        integer,
    discount        numeric(9,4),
    profit          numeric(18,4),
    hashdiff        bytea NOT NULL,
    PRIMARY KEY (order_hkey, load_dts)
) DISTRIBUTED BY (order_hkey);

-- Foreign Keys
ALTER TABLE student51.l_order_location ADD CONSTRAINT fk_lol_order FOREIGN KEY (order_hkey) REFERENCES student51.hub_order(order_hkey);
ALTER TABLE student51.l_order_location ADD CONSTRAINT fk_lol_location FOREIGN KEY (location_hkey) REFERENCES student51.hub_location(location_hkey);
ALTER TABLE student51.l_order_customer ADD CONSTRAINT fk_loc_order FOREIGN KEY (order_hkey) REFERENCES student51.hub_order(order_hkey);
ALTER TABLE student51.l_order_customer ADD CONSTRAINT fk_loc_customer FOREIGN KEY (customer_hkey) REFERENCES student51.hub_customer(customer_hkey);
ALTER TABLE student51.l_order_product ADD CONSTRAINT fk_lop_order FOREIGN KEY (order_hkey) REFERENCES student51.hub_order(order_hkey);
ALTER TABLE student51.l_order_product ADD CONSTRAINT fk_lop_product FOREIGN KEY (product_hkey) REFERENCES student51.hub_product(product_hkey);