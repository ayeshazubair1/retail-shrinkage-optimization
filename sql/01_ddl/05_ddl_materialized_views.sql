/*==================================================================================
LAYER: GOLD / AGGREGATION & PERFORMANCE (MATERIALIZED VIEWS)
Schema: gold
Purpose:
    - Improves query performance by pre-aggregating frequently used metrics
      from the 'purchases' and 'sales' tables
Usage:
    - Execute after gold fact tables are created
    - Provides fast access to totals, averages and transaction counts for analytical queries
	- Aggregates data by product, store, and vendor to reduce row count while preserving analytical granularity.
==================================================================================*/

-- View for gold.purchases table
DROP MATERIALIZED VIEW IF EXISTS gold.mv_purchases_agg;

CREATE MATERIALIZED VIEW gold.mv_purchases_agg AS 
SELECT 
    product_id,
    store_id,
    vendor_id,
    SUM(purchase_quantity) AS total_purchase_qty,
    SUM(purchase_amount) AS total_purchase_amt,
    SUM(invoice_amount) AS total_invoice_amt,
    COUNT(*) AS transaction_count,
    ROUND((SUM(purchase_amount) / NULLIF(SUM(purchase_quantity), 0)), 2) AS weighted_purchase_price,
    classification
FROM gold.purchases
GROUP BY product_id, store_id, vendor_id, classification;


-- View for gold.sales table
DROP MATERIALIZED VIEW IF EXISTS gold.mv_sales_agg;

CREATE MATERIALIZED VIEW gold.mv_sales_agg AS
SELECT 
    product_id,
    store_id,
    vendor_id,
    SUM(sale_quantity) AS total_sale_qty,
    SUM(sale_amount) AS total_sale_amt,
    COUNT(*) AS transaction_count,
    ROUND((SUM(sale_amount) / NULLIF(SUM(sale_quantity), 0)), 2) AS weighted_sale_price,
    classification
FROM gold.sales
GROUP BY product_id, store_id, vendor_id, classification;