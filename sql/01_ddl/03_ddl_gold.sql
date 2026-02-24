/*==================================================================================
LAYER: Gold / Analytics Tables
Schema: gold
Purpose: 
    - Builds normalized, analytics-ready tables
    - Data is derived from the cleaned views in the 'clean' schema
    - Enforces data integrity with Primary and Foreign Key constraints

Usage:
    - Run this script after the cleaning/transformation step
    - Drops and recreates tables to ensure a fresh load of the gold dataset
==================================================================================*/

-- 1) gold.stores

DROP TABLE IF EXISTS gold.stores;

CREATE TABLE gold.stores (
	store_id SERIAL NOT NULL,
	store_no INTEGER,
	city VARCHAR(20),
	CONSTRAINT pk_stores PRIMARY KEY (store_id)
);

-- 2) gold.vendors

DROP TABLE IF EXISTS gold.vendors;

CREATE TABLE gold.vendors (
	vendor_id SERIAL NOT NULL,
	vendor_no INTEGER,
	vendor_name VARCHAR(50),
	CONSTRAINT pk_vendors PRIMARY KEY (vendor_id)
);

-- 3) gold.products

DROP TABLE IF EXISTS gold.products;

CREATE TABLE gold.products (
	product_id SERIAL NOT NULL,
	brand_no INTEGER,
	description VARCHAR(40),
	size VARCHAR(20),
	volume INTEGER,
	classification INTEGER,
	price NUMERIC(10,2),
	purchase_price NUMERIC(10,2),
	CONSTRAINT pk_products PRIMARY KEY (product_id)
);

-- 4) gold.inventory_snapshot

DROP TABLE IF EXISTS gold.inventory_snapshot;

CREATE TABLE gold.inventory_snapshot (
	snapshot_id SERIAL NOT NULL,
	inventory_id VARCHAR(30),
	store_id INTEGER,
	product_id INTEGER,
	snapshot_date DATE,
	snapshot_type VARCHAR(10),
	on_hand INTEGER,
	price NUMERIC(10,2),
	CONSTRAINT pk_inventory_snapshot PRIMARY KEY (snapshot_id),
    CONSTRAINT fk_inventory_snapshot_stores FOREIGN KEY (store_id) REFERENCES gold.stores(store_id),
    CONSTRAINT fk_inventory_snapshot_products FOREIGN KEY (product_id) REFERENCES gold.products(product_id)
);

-- 5) gold.purchases

DROP TABLE IF EXISTS gold.purchases;

CREATE TABLE gold.purchases (
	purchase_id SERIAL NOT NULL,
	store_id INTEGER,
	product_id INTEGER,
	vendor_id INTEGER,
	po_no INTEGER,
	po_date DATE,
	receiving_date DATE,
	invoice_date DATE,
	pay_date DATE,
	purchase_price NUMERIC(10,2),
	purchase_quantity INTEGER,
	purchase_amount NUMERIC(10,2),
	invoice_amount NUMERIC(10,2),
	freight NUMERIC(10,2),
	approval VARCHAR(20),
	classification INTEGER,
	CONSTRAINT pk_purchases PRIMARY KEY (purchase_id),
    CONSTRAINT fk_purchases_stores FOREIGN KEY (store_id) REFERENCES gold.stores(store_id),
    CONSTRAINT fk_purchases_products FOREIGN KEY (product_id) REFERENCES gold.products(product_id),
    CONSTRAINT fk_purchases_vendors FOREIGN KEY (vendor_id) REFERENCES gold.vendors(vendor_id)
);

-- 6) gold.sales

DROP TABLE IF EXISTS gold.sales;

CREATE TABLE gold.sales (
	sales_id SERIAL NOT NULL,
	store_id INTEGER,
	product_id INTEGER,
	vendor_id INTEGER,
	sale_date DATE,
	sale_quantity INTEGER,
	sale_amount NUMERIC(10,2),
	sale_price NUMERIC(10,2),
	volume INTEGER,
	classification INTEGER,
	excise_tax NUMERIC(10,2),
	CONSTRAINT pk_sales PRIMARY KEY (sales_id),
    CONSTRAINT fk_sales_stores FOREIGN KEY (store_id) REFERENCES gold.stores(store_id),
    CONSTRAINT fk_sales_products FOREIGN KEY (product_id) REFERENCES gold.products(product_id),
    CONSTRAINT fk_sales_vendors FOREIGN KEY (vendor_id) REFERENCES gold.vendors(vendor_id)
);