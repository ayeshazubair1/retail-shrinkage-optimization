/*=============================================================================
    LAYER: RAW / DATA INGESTION (STORED PROCEDURE)
Schema: raw
Purpose:
    - Loads data into the 'raw' schema from external CSV files
    - Truncates the raw tables before loading data
    - Uses the `COPY` command to load data from CSV files to raw tables

Parameters:
		- None
Usage:
		- Execute with: CALL raw.load_raw();
        - Should be run prior to refreshing the 'clean' and 'gold' layers
===============================================================================*/

CREATE OR REPLACE PROCEDURE raw.load_raw()
LANGUAGE plpgsql
AS $$
BEGIN

	-- 1) raw."2017PurchasePricesDec"
    TRUNCATE TABLE raw."2017PurchasePricesDec";
    COPY raw."2017PurchasePricesDec" FROM '/Users/ayeshazubair/Developer/SQL/bibitor_llc/data_raw/2017PurchasePricesDec.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

	-- 2) raw.beginvfinal12312016
    TRUNCATE TABLE raw.beginvfinal12312016;
    COPY raw.beginvfinal12312016 FROM '/Users/ayeshazubair/Developer/SQL/bibitor_llc/data_raw/BegInvFINAL12312016.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

	-- 3) raw.endinvfinal12312016
    TRUNCATE TABLE raw.endinvfinal12312016;
    COPY raw.endinvfinal12312016 FROM '/Users/ayeshazubair/Developer/SQL/bibitor_llc/data_raw/EndInvFINAL12312016.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

	-- 4) raw.invoicepurchases12312016
    TRUNCATE TABLE raw.invoicepurchases12312016;
    COPY raw.invoicepurchases12312016 FROM '/Users/ayeshazubair/Developer/SQL/bibitor_llc/data_raw/InvoicePurchases12312016.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

	-- 5) raw.purchasesfinal12312016
    TRUNCATE TABLE raw.purchasesfinal12312016;
    COPY raw.purchasesfinal12312016 FROM '/Users/ayeshazubair/Developer/SQL/bibitor_llc/data_raw/PurchasesFINAL12312016.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

	-- 6) raw.salesfinal12312016
    TRUNCATE TABLE raw.salesfinal12312016;
    COPY raw.salesfinal12312016 FROM '/Users/ayeshazubair/Developer/SQL/bibitor_llc/data_raw/SalesFINAL12312016.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
END;
$$;

CALL raw.load_raw();