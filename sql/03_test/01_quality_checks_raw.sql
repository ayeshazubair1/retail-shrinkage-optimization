/*=========================================================
LAYER: RAW / DATA QUALITY CHECKS
Schema: raw
No. of tables - 6
===========================================================
Purpose:
    - Validates raw/source data for completeness, accuracy, and consistency
    - Identifies nulls, duplicates, negative values, inconsistent formatting, and calculation errors
    - Detects standardization issues in strings, dates, and numeric fields
    - Ensures data is fit for transformation and modeling

Usage Notes:
       - Run prior to the clean/transformation steps
       - Investigate, correct, and document any anomalies discovered
==========================================================*/

-- ============================
-- 1) raw."2017PurchasePricesDec"
-- ============================

-- Check: NULL or negative values in 'brand'
-- Result: No issues
SELECT brand
FROM raw."2017PurchasePricesDec"
WHERE brand IS NULL 
	OR brand <= 0;

-- Check: NULL or Unwanted spaces in 'description'
-- Result: No issues
SELECT description 
FROM raw."2017PurchasePricesDec"
WHERE description IS NULL
	OR description != TRIM(description);

-- Check: NULL or negative values in 'price'
-- Result: No issues
SELECT price
FROM raw."2017PurchasePricesDec"
WHERE price < 0 
	OR price IS NULL ;

-- Check: Data standardization & consistency in 'size'/'volume'
-- Result: Inconsistent and empty values found – (needs fixing)
SELECT DISTINCT "Size" FROM raw."2017PurchasePricesDec"; 	
SELECT DISTINCT "Volume" FROM raw."2017PurchasePricesDec";

-- Check: NULL or negative values in 'purchaseprice'
-- Result: No issues
SELECT purchaseprice
FROM raw."2017PurchasePricesDec"
WHERE purchaseprice < 0 
	OR purchaseprice IS NULL ;

-- Check: NULL or negative values in 'vendornumber'
-- Result: No issues
SELECT vendornumber
FROM raw."2017PurchasePricesDec"
WHERE vendornumber < 0 
	OR vendornumber IS NULL ;

-- Check: Unwanted spaces in 'vendorname'
-- Result: 10407 records found – (needs fixing)
SELECT 
	vendorname,
	COUNT(*) OVER () AS total_untrimmed
FROM raw."2017PurchasePricesDec"
WHERE vendorname <> TRIM(vendorname);

-- ================================
-- 2) raw.beginvfinal12312016
-- ================================

-- Check: NULL duplicate or empty values in 'InventoryId'
-- Result: No issues
SELECT 
	"InventoryId", 
	COUNT(*)
FROM raw.beginvfinal12312016
WHERE 
	"InventoryId" IS NULL  
	OR TRIM("InventoryId") = ''
GROUP BY "InventoryId"
HAVING COUNT(*) > 1 ;

-- Check: NULL or negative values in 'Store'
--Result: No issues
SELECT "Store"
FROM raw.beginvfinal12312016
WHERE "Store" IS NULL 
	OR "Store" <= 0;

-- Check: NULL or empty values in 'City'
-- Result: No issues
SELECT "City"
FROM raw.beginvfinal12312016
WHERE "City" IS NULL  
	OR TRIM("City") = '';

-- Check: NULL  or non-postive values in 'Brand'
-- Result: No issues
SELECT "Brand"
FROM raw.beginvfinal12312016
WHERE "Brand" IS NULL 
	OR "Brand" <= 0;	 

-- Check: NULL or empty values in 'Description'
-- Result: No issues
SELECT "Description" 
FROM raw.beginvfinal12312016
WHERE "Description" <> TRIM("Description") 
	OR "Description" IS NULL ;

-- Check: Data standardization & consistency in 'Size'
-- Result: Inconsistent values found – (needs fixing)
SELECT DISTINCT "Size"
FROM raw.beginvfinal12312016;

-- Check: NULL or negative values in 'onHand'
-- Result: No issues
SELECT "onHand"
FROM raw.beginvfinal12312016
WHERE "onHand" IS NULL 
	OR "onHand" < 0;

-- Check: NULL, extra spaces, or incorrect length in 'startDate'
-- Result: No issues
SELECT "startDate"
FROM raw.beginvfinal12312016
WHERE 
	"startDate" IS NULL  
	OR "startDate" <> TRIM("startDate")
	OR LENGTH("startDate" ::text) <> 10;

-- ================================
-- 3) raw.endinvfinal12312016
-- ================================

-- Check: NULL, duplicate or empty values in 'InventoryId'
-- Result: No issues
SELECT 
	"InventoryId", 
	COUNT(*)
FROM raw.endinvfinal12312016 
GROUP BY "InventoryId"
HAVING 
	COUNT(*) > 1 
	OR "InventoryId" IS NULL  
	OR TRIM("InventoryId") = '';

-- Check: NULL or empty values in 'City'
-- Result: 1284 records found – (needs fixing)
SELECT 
	"City",
	COUNT("City")
FROM raw.endinvfinal12312016
WHERE 
	"City" IS NULL  
	OR TRIM("City") = ''
GROUP BY "City";

-- Check: Data standardization & consistency in 'Size'
-- Result: Inconsistent values found – (needs fixing)
SELECT DISTINCT "Size" FROM raw.endinvfinal12312016;

-- Check: NULL or negative values in 'Price'
-- Result: No issues
SELECT "Price"
FROM raw.endinvfinal12312016
WHERE "Price" IS NULL 	
	OR "Price" < 0;

-- Check: NULL, extra spaces, or incorrect length in 'endDate'
-- Result: No issues
SELECT "endDate"
FROM raw.endinvfinal12312016  
WHERE 
	"endDate" IS NULL  
	OR "endDate" <> TRIM("endDate")
    OR LENGTH("endDate"::text) != 10;

-- =====================================
-- 4) raw.invoicepurchases12312016
-- =====================================

-- Check: NULL or empty values in 'VendorNumber'
-- Result: No issues
SELECT "VendorNumber"
FROM raw.invoicepurchases12312016
WHERE "VendorNumber" IS NULL  
	OR "VendorNumber" < 0;

-- Check: Unwanted spaces in 'VendorName'
-- Result: 5133 records found – (needs fixing)
SELECT 
	"VendorName",
	COUNT(*) OVER () AS unwanted_spaces_count
FROM raw.invoicepurchases12312016 
WHERE "VendorName" <> TRIM("VendorName");

-- Check: NULL, extra spaces, or incorrect length in 'InvoiceDate'
-- Result: No issues
SELECT "InvoiceDate"
FROM raw.invoicepurchases12312016 
WHERE 
	"InvoiceDate" IS NULL  
	OR "InvoiceDate" <> TRIM("InvoiceDate")
    OR LENGTH("InvoiceDate"::text) != 10;

-- Check: NULL or negative values in 'PONumber'
--Result: No issues
SELECT "PONumber"
FROM raw.invoicepurchases12312016 
WHERE "PONumber" IS NULL  
	OR "PONumber" <= 0;

-- Check: NULL, extra spaces, or incorrect length in 'PayDate'
-- Result: No issues
SELECT "PayDate"
FROM raw.invoicepurchases12312016 
WHERE 
	"PayDate" IS NULL  
	OR "PayDate" = ''
    OR LENGTH("PayDate"::text) != 10;

-- Check for NULL or non-positive values in 'Quantity'
-- Result: No issues
SELECT "Quantity"
FROM raw.invoicepurchases12312016 
WHERE "Quantity" IS NULL  
	OR "Quantity" < 0;

-- Check: NULL or negative values in 'Dollars'
-- Result: No issues
SELECT "Dollars"
FROM raw.invoicepurchases12312016 
WHERE "Dollars" IS NULL  
	OR "Dollars" < 0;

-- Check: NULL or negative values in 'Freight'
-- Result: No issues
SELECT "Freight"
FROM raw.invoicepurchases12312016 
WHERE "Freight" IS NULL  
	OR "Freight" < 0;

-- ===================================
-- 5) raw.purchasesfinal12312016
-- ===================================

-- Check: NULL, empty, or inconsistent values in 'Size'
-- Result: Inconsistent values found – (needs fixing)
SELECT DISTINCT  "Size"
FROM raw.purchasesfinal12312016;

SELECT 
	"Size"
FROM raw.purchasesfinal12312016 
WHERE 
	"Size" IS NULL 
	OR "Size" = '';

-- Check: Unwanted spaces in 'VendorName'
-- Result: 2170689 records found – (needs fixing)
SELECT COUNT(*)
FROM
	(SELECT "VendorName"
	FROM raw.purchasesfinal12312016  
	WHERE "VendorName" <> RTRIM("VendorName")
	)t;

-- Check: NULL, empty, or incorrect length in 'ReceivingDate'
-- Result: No issues
SELECT "ReceivingDate"
FROM raw.purchasesfinal12312016   
WHERE 
	"ReceivingDate" IS NULL  
	OR "ReceivingDate" = ''
    OR LENGTH("ReceivingDate"::text) != 10;

-- Check: NULL, empty, or incorrect length in 'InvoiceDate'
-- Result: No issues
SELECT "InvoiceDate"
FROM raw.purchasesfinal12312016   
WHERE 
	"InvoiceDate" IS NULL  
	OR "InvoiceDate" = ''
    OR LENGTH("InvoiceDate"::text) != 10;

-- Check: NULL, empty, or incorrect length in 'PayDate'
-- Result: No issues
SELECT "PayDate"
FROM raw.purchasesfinal12312016  
WHERE 
	"PayDate" IS NULL  
	OR "PayDate" = ''
    OR LENGTH("PayDate"::text) != 10;

-- Check: NULL or negative values in 'PurchasePrice'
-- Result: No issues
SELECT "PurchasePrice"
FROM raw.purchasesfinal12312016 
WHERE "PurchasePrice" IS NULL  
	OR "PurchasePrice" < 0;

-- Check: 'Dollars' not equal to 'PurchasePrice' * 'Quantity'
-- Result: Incorrect values found – (needs fixing)
SELECT "Dollars" 
FROM raw.purchasesfinal12312016 
WHERE "Dollars" <> "PurchasePrice" * "Quantity" ;

-- ================================
-- 6) raw.salesfinal12312016
-- ================================

-- Check: NULL, or empty values in 'InventoryId'
-- Result: No issues
SELECT 
	"InventoryId" 
FROM raw.salesfinal12312016 
WHERE 
	"InventoryId" IS NULL 
	OR TRIM("InventoryId") = '';

-- Check Data standardization & consistency in 'Size'
-- Result: inconsistent values found – (needs fixing)
SELECT DISTINCT  "Size" FROM raw.salesfinal12312016 

-- Check: NULL or negative values in 'SalesQuantity'
-- Result: No issues
SELECT "SalesQuantity"
FROM raw.salesfinal12312016 
WHERE "SalesQuantity" IS NULL  
	OR "SalesQuantity" < 1;

-- Check: NULL or negative values in 'SalesDollars'
-- Result: No issues
SELECT "SalesDollars"
FROM raw.salesfinal12312016 
WHERE "SalesDollars" IS NULL  
	OR "SalesDollars" <= 0;

-- Check: 'SalesDollars' not equal to 'SalesPrice' * 'SalesQuantity'
-- Result: Incorrect values found – (needs fixing)
SELECT "SalesDollars"  
FROM raw.salesfinal12312016  
WHERE "SalesDollars" <> "SalesPrice" * "SalesQuantity";

-- Check: NULL or negative values in 'SalesPrice'
-- Result: No issues
SELECT "SalesPrice"
FROM raw.salesfinal12312016 
WHERE "SalesPrice" IS NULL  
	OR "SalesPrice" < 0;

-- Check: NULL, empty, or incorrect length in 'SalesDate'
-- Result: No issues
SELECT "SalesDate"
FROM raw.salesfinal12312016  
WHERE 
	"SalesDate" IS NULL  
	OR "SalesDate" = ''
    OR LENGTH("SalesDate"::text) != 10;

-- Check: NULL or negative values in 'ExciseTax'
-- Result: No issues 
SELECT "ExciseTax"
FROM raw.salesfinal12312016 
WHERE "ExciseTax" IS NULL 
	OR "ExciseTax" < 0;

-- Check for NULL  or empty values in 'VendorName'
-- Result: No issues
SELECT "VendorName"
FROM raw.salesfinal12312016 
WHERE "VendorName" IS NULL  
	OR "VendorName" = '';

-- Check: Unwanted spaces in 'VendorName'
-- Result: 11719199 records found – (needs fixing)
SELECT 
	"VendorName",
	COUNT(*) OVER () AS total_untrimmed
FROM raw.salesfinal12312016 
WHERE "VendorName" <> TRIM("VendorName");