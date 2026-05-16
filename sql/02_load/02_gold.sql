/*==================================================================================== 
LAYER: GOLD / LOAD FINAL TABLES (STORED PROCEDURE)
Schema: gold
Purpose: 
	- Populate final analytics-ready gold tables from cleaned data
	- Ensures de-duplicated, normalized, and linked data for gold tables
	- Truncate to remove all existing records, ensuring a clean load of new data

Parameters:
     - None

Usage:
     - Execute after the clean/transformation layer is refreshed
     - Run with: CALL gold.load_gold();
     - Supports downstream analytics, dashboards, and reporting
======================================================================================*/

CREATE OR REPLACE PROCEDURE gold.load_gold()
LANGUAGE plpgsql
AS $$
BEGIN
	-- 1) gold.stores
	TRUNCATE TABLE gold.stores;
	
	INSERT INTO gold.stores (store_no, city)
	SELECT
	    t.store_no,
	    COALESCE(b.city, e.city) AS city
	FROM (
	    SELECT store AS store_no FROM clean.beginvfinal12312016
	    UNION
	    SELECT store AS store_no FROM clean.endinvfinal12312016
	    UNION
	    SELECT store AS store_no FROM clean.purchasesfinal12312016
	    UNION
	    SELECT store AS store_no FROM clean.salesfinal12312016
	) t
	LEFT JOIN (SELECT DISTINCT store, city FROM clean.beginvfinal12312016) b ON t.store_no = b.store
	LEFT JOIN (SELECT DISTINCT store, city FROM clean.endinvfinal12312016) e ON t.store_no = e.store
	GROUP BY 1, 2;
	
	-- 2) gold.vendors
	TRUNCATE TABLE gold.vendors;
	
	INSERT INTO gold.vendors (vendor_no, vendor_name)
	SELECT DISTINCT vendor_number, vendor_name
	FROM (
	    SELECT vendor_number, vendor_name FROM clean."2017PurchasePricesDec"
	    UNION
	    SELECT vendor_number, vendor_name FROM clean.invoicepurchases12312016
	    UNION
	    SELECT vendor_number, vendor_name FROM clean.salesfinal12312016
	    UNION
	    SELECT vendor_number, vendor_name FROM clean.purchasesfinal12312016
	) t;

	-- 3) gold.products
	TRUNCATE TABLE gold.products;
	
	INSERT INTO gold.products (brand_no, description, size, volume, classification, price, purchase_price)
	SELECT
	    brand_id,
	    description,
	    size,
	    MAX(volume) AS volume,
	    MAX(classification) AS classification,
	    MAX(price) AS price,
	    MAX(purchase_price) AS purchase_price
	FROM (
	    SELECT brand_id, description, size, volume, classification, price, purchase_price FROM clean."2017PurchasePricesDec"
	    UNION ALL
	    SELECT brand_id, description, size, NULL AS volume, NULL AS classification, price, NULL AS purchase_price FROM clean.beginvfinal12312016
	    UNION ALL
	    SELECT brand_id, description, size, NULL AS volume, NULL AS classification, price, NULL AS purchase_price FROM clean.endinvfinal12312016
	    UNION ALL
	    SELECT brand_id, description, size, volume, classification, NULL AS price, NULL AS purchase_price FROM clean.salesfinal12312016
	    UNION ALL
	    SELECT brand_id, description, size, NULL AS volume, classification, NULL AS price, purchase_price FROM clean.purchasesfinal12312016
	) t
	GROUP BY brand_id, description, size;
	
	-- 4) gold.inventory_snapshot
	TRUNCATE TABLE gold.inventory_snapshot;
	
	INSERT INTO gold.inventory_snapshot (inventory_id, store_id, product_id, snapshot_date, snapshot_type, on_hand, price)
	SELECT
	    t.inventory_id,
	    s.store_id,
	    p.product_id,
	    t.snapshot_date,
	    t.snapshot_type,
	    t.on_hand,
	    t.price
	FROM (
	    SELECT 
	        inventory_id, store, brand_id, description, size, start_date AS snapshot_date, 'start' AS snapshot_type, on_hand, price FROM clean.beginvfinal12312016
	    UNION ALL
	    SELECT 
	        inventory_id, store, brand_id, description, size, end_date AS snapshot_date, 'end' AS snapshot_type, on_hand, price FROM clean.endinvfinal12312016
	) t
	LEFT JOIN gold.stores s   ON t.store = s.store_no
	LEFT JOIN gold.products p ON t.brand_id = p.brand_no AND t.description = p.description AND t.size = p.size;

	-- 5) gold.purchases
	TRUNCATE TABLE gold.purchases;
	
	INSERT INTO gold.purchases (store_id, product_id, vendor_id, po_no, po_date, receiving_date, invoice_date, pay_date, purchase_price, quantity, purchase_amount, invoice_amount, freight, approval, classification)
	SELECT
	    s.store_id,
	    p.product_id,
	    v.vendor_id,
	    c.po_number,
	    c.po_date,
	    c.receiving_date,
	    c.invoice_date,
	    c.pay_date,
	    c.purchase_price,
	    c.purchase_quantity,
	    c.purchase_amount,
	    i.invoice_amount,
	    i.freight,
	    i.approval,
	    c.classification
	FROM clean.purchasesfinal12312016 c
	LEFT JOIN clean.invoicepurchases12312016 i ON c.vendor_number = i.vendor_number AND c.po_number = i.po_number AND c.invoice_date = i.invoice_date
	LEFT JOIN gold.stores s   ON c.store = s.store_no
	LEFT JOIN gold.products p ON c.brand_id = p.brand_no AND c.description = p.description AND c.size = p.size
	LEFT JOIN gold.vendors v  ON c.vendor_number = v.vendor_no;

	-- 6) gold.sales
	TRUNCATE TABLE gold.sales;
	
	INSERT INTO gold.sales (store_id, product_id, vendor_id, sales_date, sales_quantity, sales_amount, sales_price, volume, classification, excise_tax)
	SELECT
	    s.store_id,
	    p.product_id,
	    v.vendor_id,
	    t.sale_date,
	    t.sale_quantity,
	    t.sale_amount,
	    t.sale_price,
	    t.volume,
	    t.classification,
	    t.excise_tax
	FROM clean.salesfinal12312016 t
	LEFT JOIN gold.stores s   ON t.store = s.store_no
	LEFT JOIN gold.products p ON t.brand_id = p.brand_no AND t.description = p.description AND t.size = p.size
	LEFT JOIN gold.vendors v  ON t.vendor_number = v.vendor_no;

END;
$$;

CALL gold.load_gold();