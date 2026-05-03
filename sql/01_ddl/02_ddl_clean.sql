/*=======================================================================================
LAYER: Clean / Standardized Views
Schema: clean
Purpose: 
	- Creates cleaned transformed views, derived from the raw/source tables in the 'raw' schema
    - Resolves known data quality issues (formats, casing, null, duplicates)

Usage:
	- Run this script to create or refresh views showing cleaned data
    - These views can be used for validation, or as a source for final tables
=========================================================================================*/

-- Function to normalize 'Size' column
CREATE OR REPLACE FUNCTION clean.normalize_size(sz TEXT) RETURNS VARCHAR(50) AS $$
DECLARE
    n NUMERIC;
BEGIN
    IF     sz IS NULL OR TRIM(sz) = '' OR LOWER(sz) = 'unknown' THEN RETURN 'n/a';
    ELSIF  LOWER(sz) ~ '[0-9.]+ *ml' THEN
        n := (REGEXP_MATCH(LOWER(sz), '([0-9.]+) *ml'))[1]::NUMERIC;
        RETURN ROUND(n)::TEXT || 'ml';
    ELSIF  LOWER(sz) ~ '[0-9.]+ *(l|liter)' THEN
        n := (REGEXP_MATCH(LOWER(sz), '([0-9.]+) *(l|liter)'))[1]::NUMERIC * 1000;
        RETURN ROUND(n)::TEXT || 'ml';
    ELSIF  LOWER(sz) IN ('liter', 'l') THEN RETURN '1000ml';
    ELSIF  LOWER(sz) ~ '[0-9.]+ *oz' THEN
        n := (REGEXP_MATCH(LOWER(sz), '([0-9.]+) *oz'))[1]::NUMERIC * 29.5735;
        RETURN ROUND(n)::TEXT || 'ml';
    ELSIF  LOWER(sz) ~ '[0-9.]+ *gal' THEN
        n := (REGEXP_MATCH(LOWER(sz), '([0-9.]+) *gal'))[1]::NUMERIC * 3785.41;
        RETURN ROUND(n)::TEXT || 'ml';
    ELSIF  LOWER(sz) ~ '^[0-9.]+$' THEN
        RETURN ROUND(sz::NUMERIC * 10)::TEXT || 'ml';
    ELSIF  LOWER(sz) ~ '^[0-9]+/[0-9]+ *oz' THEN
        n := (SPLIT_PART(sz, '/', 1)::NUMERIC / SPLIT_PART(SPLIT_PART(sz, ' ', 1), '/', 2)::NUMERIC) * 29.5735;
        RETURN ROUND(n)::TEXT || 'ml';
    ELSE   RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- 1) clean."2017PurchasePricesDec"
CREATE OR REPLACE VIEW clean."2017PurchasePricesDec" AS
SELECT
    brand::INTEGER                                                    AS brand_id,
    LOWER(TRIM(description::VARCHAR(50)))                             AS description,
    ROUND(price::NUMERIC, 2)                                          AS price,
    clean.normalize_size("Size")                                      AS size,
    NULLIF(NULLIF(LOWER(TRIM("Volume")), ''), 'unknown')::NUMERIC     AS volume,
    classification::INTEGER                                           AS classification,
    ROUND(purchaseprice::NUMERIC, 2)                                  AS purchase_price,
    vendornumber::INTEGER                                             AS vendor_number,
    LOWER(TRIM(vendorname::VARCHAR(50)))                              AS supplier
FROM raw."2017PurchasePricesDec";

-- 2) clean.beginvfinal12312016
CREATE OR REPLACE VIEW clean.beginvfinal12312016 AS
SELECT
    "InventoryId"::VARCHAR(50)               AS inventory_id,
    "Store"::INTEGER                         AS store,
    INITCAP(LOWER("City"::VARCHAR(50)))      AS city,
    "Brand"::INTEGER                         AS brand_id,
    LOWER("Description"::VARCHAR(50))        AS description,
    clean.normalize_size("Size")             AS size,
    "onHand"::INTEGER                        AS on_hand,
    ROUND("Price"::NUMERIC, 2)               AS price,
    "startDate"::DATE                        AS start_date
FROM raw.beginvfinal12312016;

-- 3) clean.endinvfinal12312016
CREATE OR REPLACE VIEW clean.endinvfinal12312016 AS
SELECT
    "InventoryId"::VARCHAR(50)               AS inventory_id,
    "Store"::INTEGER                         AS store,
    INITCAP(LOWER("City"::VARCHAR(50)))      AS city,
    "Brand"::INTEGER                         AS brand_id,
    LOWER("Description"::VARCHAR(50))        AS description,
    clean.normalize_size("Size")             AS size,
    "onHand"::INTEGER                        AS on_hand,
    ROUND("Price"::NUMERIC, 2)               AS price,
    "endDate"::DATE                          AS end_date
FROM raw.endinvfinal12312016;

-- 4) clean.invoicepurchases12312016
CREATE OR REPLACE VIEW clean.invoicepurchases12312016 AS
SELECT
    "VendorNumber"::INTEGER                       AS vendor_number,
    LOWER(TRIM("VendorName"::VARCHAR(50)))        AS supplier,
    "InvoiceDate"::DATE                           AS invoice_date,
    "PONumber"::INTEGER                           AS po_number,
    "PODate"::DATE                                AS po_date,
    "PayDate"::DATE                               AS pay_date,
    "Quantity"::INTEGER                           AS quantity,
    ROUND("Dollars"::NUMERIC, 2)                  AS invoice_amount,
    ROUND("Freight"::NUMERIC, 2)                  AS freight,
    COALESCE(NULLIF("Approval", 'None'), 'n/a')   AS approval
FROM raw.invoicepurchases12312016;

-- 5) clean.salesfinal12312016
CREATE OR REPLACE VIEW clean.salesfinal12312016 AS
SELECT
    "InventoryId"::VARCHAR(50)                                AS inventory_id,
    "Store"::INTEGER                                          AS store,
    "Brand"::INTEGER                                          AS brand_id,
    LOWER("Description"::VARCHAR(50))                         AS description,
    clean.normalize_size("Size")                              AS size,
    "SalesQuantity"::INTEGER                                  AS sales_quantity,
    ROUND(("SalesPrice" * "SalesQuantity")::NUMERIC, 2)       AS sales_amount,
    ROUND("SalesPrice"::NUMERIC, 2)                           AS sales_price,
    "SalesDate"::DATE                                         AS sale_date,
    "Volume"::INTEGER                                         AS volume,
    "Classification"::INTEGER                                 AS classification,
    ROUND("ExciseTax"::NUMERIC, 2)                            AS excise_tax,
    "VendorNo"::INTEGER                                       AS vendor_number,
    TRIM(LOWER("VendorName"::VARCHAR(50)))                    AS supplier
FROM raw.salesfinal12312016;

-- 6) clean.purchasesfinal12312016
CREATE OR REPLACE VIEW clean.purchasesfinal12312016 AS
SELECT
    "InventoryId"::VARCHAR(50)                                 AS inventory_id,
    "Store"::INTEGER                                           AS store,
    "Brand"::INTEGER                                           AS brand_id,
    LOWER("Description"::VARCHAR(50))                          AS description,
    clean.normalize_size("Size")                               AS size,
    "VendorNumber"::INTEGER                                    AS vendor_number,
    TRIM("VendorName"::VARCHAR(50))                            AS supplier,
    "PONumber"::INTEGER                                        AS po_number,
    "PODate"::DATE                                             AS po_date,
    "ReceivingDate"::DATE                                      AS receiving_date,
    "InvoiceDate"::DATE                                        AS invoice_date,
    "PayDate"::DATE                                            AS pay_date,
    ROUND("PurchasePrice"::NUMERIC, 2)                         AS purchase_price,
    "Quantity"::INTEGER                                        AS quantity,
    ROUND(("PurchasePrice" * "Quantity")::NUMERIC, 2)          AS purchase_amount,
    "Classification"::INTEGER                                  AS classification
FROM raw.purchasesfinal12312016;