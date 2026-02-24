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
    "Brand" integer NULL,
    "Description" varchar(50) NULL,
    "Price" real NULL,
    "Size" varchar(50) NULL,
    "Volume" varchar(50) NULL,
    "Classification" integer NULL,
    "PurchasePrice" real NULL,
    "VendorNumber" integer NULL,
    "VendorName" varchar(50) NULL
);

-- 2) raw.beginvfinal12312016

DROP TABLE IF EXISTS raw.beginvfinal12312016;

CREATE TABLE raw.beginvfinal12312016 (
    "InventoryId" varchar(50) NULL,
    "Store" integer NULL,
    "City" varchar(50) NULL,
    "Brand" integer NULL,
    "Description" varchar(50) NULL,
    "Size" varchar(50) NULL,
    "onHand" integer NULL,
    "Price" real NULL,
    "startDate" varchar(50) NULL
);

-- 3) raw.endinvfinal12312016

DROP TABLE IF EXISTS raw.endinvfinal12312016;

CREATE TABLE raw.endinvfinal12312016 (
    "InventoryId" varchar(50) NULL,
    "Store" integer NULL,
    "City" varchar(50) NULL,
    "Brand" integer NULL,
    "Description" varchar(50) NULL,
    "Size" varchar(50) NULL,
    "onHand" integer NULL,
    "Price" real NULL,
    "endDate" varchar(50) NULL
);

-- 4) raw.invoicepurchases12312016

DROP TABLE IF EXISTS raw.invoicepurchases12312016;

CREATE TABLE raw.invoicepurchases12312016 (
    "VendorNumber" integer NULL,
    "VendorName" varchar(50) NULL,
    "InvoiceDate" varchar(50) NULL,
    "PONumber" integer NULL,
    "PODate" varchar(50) NULL,
    "PayDate" varchar(50) NULL,
    "Quantity" integer NULL,
    "Dollars" real NULL,
    "Freight" real NULL,
    "Approval" varchar(50) NULL
);

-- 5) raw.purchasesfinal12312016

DROP TABLE IF EXISTS raw.purchasesfinal12312016;

CREATE TABLE raw.purchasesfinal12312016 (
    "InventoryId" varchar(50) NULL,
    "Store" integer NULL,
    "Brand" integer NULL,
    "Description" varchar(50) NULL,
    "Size" varchar(50) NULL,
    "VendorNumber" integer NULL,
    "VendorName" varchar(50) NULL,
    "PONumber" integer NULL,
    "PODate" varchar(50) NULL,
    "ReceivingDate" varchar(50) NULL,
    "InvoiceDate" varchar(50) NULL,
    "PayDate" varchar(50) NULL,
    "PurchasePrice" real NULL,
    "Quantity" integer NULL,
    "Dollars" real NULL,
    "Classification" integer NULL
);

-- 6) raw.salesfinal12312016

DROP TABLE IF EXISTS raw.salesfinal12312016;

CREATE TABLE raw.salesfinal12312016 (
    "InventoryId" varchar(50) NULL,
    "Store" integer NULL,
    "Brand" integer NULL,
    "Description" varchar(50) NULL,
    "Size" varchar(50) NULL,
    "SalesQuantity" integer NULL,
    "SalesDollars" real NULL,
    "SalesPrice" real NULL,
    "SalesDate" varchar(50) NULL,
    "Volume" integer NULL,
    "Classification" integer NULL,
    "ExciseTax" real NULL,
    "VendorNo" integer NULL,
    "VendorName" varchar(50) NULL
);