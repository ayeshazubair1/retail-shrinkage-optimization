/*==================================================================================
LAYER: GOLD / PERFORMANCE OPTIMIZATION (INDEXES)
Schema: gold
Purpose:
    - Improves query performance on frequently filtered or joined columns
    - Indexes are created on the 'purchases' and 'sales' tables where filtering, 
      joining, or date-based aggregation is most common

Usage:
    - Run after creating the GOLD (final) tables
    - Helps speed up analytics queries, reporting, and dashboard performance
==================================================================================*/

-- Indexes for gold.purchases table

CREATE INDEX idx_purchases_store ON gold.purchases(store_id);

CREATE INDEX idx_purchases_product ON gold.purchases(product_id);

CREATE INDEX idx_purchases_vendor ON gold.purchases(vendor_id);

CREATE INDEX idx_purchases_po_date ON gold.purchases(po_date);

-- Indexes for gold.sales table

CREATE INDEX idx_sales_store ON gold.sales(store_id);

CREATE INDEX idx_sales_product ON gold.sales(product_id);

CREATE INDEX idx_sales_date ON gold.sales(sale_date);