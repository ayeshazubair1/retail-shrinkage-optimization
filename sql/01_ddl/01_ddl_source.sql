/*=====================================================================================
LAYER: Raw / Source (DATA INGESTION)
Schema: raw
Purpose: 
		- Defines raw ingestion tables that mirror source files exactly
        - Preserves original structure, naming, and data types
Usage:
    - Run this script to load source tables to hold unprocessed data before cleaning or transformation.
=======================================================================================*/

-- 1) raw."2017PurchasePricesDec"
DROP TABLE IF EXISTS raw."2017PurchasePricesDec";
CREATE TABLE raw."2017PurchasePricesDec" (
    "Brand"          INTEGER     NULL,
    "Description"    VARCHAR(50) NULL,
    "Price"          REAL        NULL,
    "Size"           VARCHAR(50) NULL,
    "Volume"         VARCHAR(50) NULL,
    "Classification" INTEGER     NULL,
    "PurchasePrice"  REAL        NULL,
    "VendorNumber"   INTEGER     NULL,
    "VendorName"     VARCHAR(50) NULL
);

-- 2) raw.beginvfinal12312016
DROP TABLE IF EXISTS raw.beginvfinal12312016;
CREATE TABLE raw.beginvfinal12312016 (
    "InventoryId" VARCHAR(50) NULL,
    "Store"       INTEGER     NULL,
    "City"        VARCHAR(50) NULL,
    "Brand"       INTEGER     NULL,
    "Description" VARCHAR(50) NULL,
    "Size"        VARCHAR(50) NULL,
    "onHand"      INTEGER     NULL,
    "Price"       REAL        NULL,
    "startDate"   VARCHAR(50) NULL
);

-- 3) raw.endinvfinal12312016
DROP TABLE IF EXISTS raw.endinvfinal12312016;
CREATE TABLE raw.endinvfinal12312016 (
    "InventoryId" VARCHAR(50) NULL,
    "Store"       INTEGER     NULL,
    "City"        VARCHAR(50) NULL,
    "Brand"       INTEGER     NULL,
    "Description" VARCHAR(50) NULL,
    "Size"        VARCHAR(50) NULL,
    "onHand"      INTEGER     NULL,
    "Price"       REAL        NULL,
    "endDate"     VARCHAR(50) NULL
);

-- 4) raw.invoicepurchases12312016
DROP TABLE IF EXISTS raw.invoicepurchases12312016;
CREATE TABLE raw.invoicepurchases12312016 (
    "VendorNumber" INTEGER     NULL,
    "VendorName"   VARCHAR(50) NULL,
    "InvoiceDate"  VARCHAR(50) NULL,
    "PONumber"     INTEGER     NULL,
    "PODate"       VARCHAR(50) NULL,
    "PayDate"      VARCHAR(50) NULL,
    "Quantity"     INTEGER     NULL,
    "Dollars"      REAL        NULL,
    "Freight"      REAL        NULL,
    "Approval"     VARCHAR(50) NULL
);

-- 5) raw.purchasesfinal12312016
DROP TABLE IF EXISTS raw.purchasesfinal12312016;
CREATE TABLE raw.purchasesfinal12312016 (
    "InventoryId"    VARCHAR(50) NULL,
    "Store"          INTEGER     NULL,
    "Brand"          INTEGER     NULL,
    "Description"    VARCHAR(50) NULL,
    "Size"           VARCHAR(50) NULL,
    "VendorNumber"   INTEGER     NULL,
    "VendorName"     VARCHAR(50) NULL,
    "PONumber"       INTEGER     NULL,
    "PODate"         VARCHAR(50) NULL,
    "ReceivingDate"  VARCHAR(50) NULL,
    "InvoiceDate"    VARCHAR(50) NULL,
    "PayDate"        VARCHAR(50) NULL,
    "PurchasePrice"  REAL        NULL,
    "Quantity"       INTEGER     NULL,
    "Dollars"        REAL        NULL,
    "Classification" INTEGER     NULL
);

-- 6) raw.salesfinal12312016
DROP TABLE IF EXISTS raw.salesfinal12312016;
CREATE TABLE raw.salesfinal12312016 (
    "InventoryId"    VARCHAR(50) NULL,
    "Store"          INTEGER     NULL,
    "Brand"          INTEGER     NULL,
    "Description"    VARCHAR(50) NULL,
    "Size"           VARCHAR(50) NULL,
    "SalesQuantity"  INTEGER     NULL,
    "SalesDollars"   REAL        NULL,
    "SalesPrice"     REAL        NULL,
    "SalesDate"      VARCHAR(50) NULL,
    "Volume"         INTEGER     NULL,
    "Classification" INTEGER     NULL,
    "ExciseTax"      REAL        NULL,
    "VendorNo"       INTEGER     NULL,
    "VendorName"     VARCHAR(50) NULL
);