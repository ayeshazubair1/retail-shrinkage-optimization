/*=====================================================================================
-- BUSINESS QUESTION: Are high-value products shrinking at different rates than low-value items?

-- PURPOSE: Analyze inventory shrinkage by product value to identify if high-value SKUs are losing stock 
--          at higher rates than low-value SKUs, which may indicate risk areas for loss prevention.

-- DATA & SCOPE:
--   - Sales and purchase data from materialized views (mv_sales_agg, mv_purchases_agg)
--   - Only products with recorded sales and inventory snapshots are included
--   - High-value products: top 25% by weighted average sale price; others categorized as low-value

-- APPROACH:
--   1. Calculate weighted average sale price per product
--   2. Aggregate inventory (start & end) and total purchased and sold quantities per product
--   3. Compute units_lost and loss_rate per product
--   4. Summarize positive shrinkage count and average loss_rate by category

-- ASSUMPTIONS & NOTES:
--   - Only positive shrinkage considered (actual loss)
--   - Purchase price is not used in shrinkage calculation; focus is on sale price categories
--   - Percentile thresholds chosen to define high-value products (75th percentile)

-- OUTPUT: Shrinkage summary table showing number of products with positive shrinkage, total monetary_value 
--         and average loss_rate by product value category.
=====================================================================================*/

WITH product_price AS (
	SELECT 
		product_id,
		ROUND(SUM(weighted_sale_price * total_sale_qty) / NULLIF(SUM(total_sale_qty), 0), 2) AS sale_price
	FROM gold.mv_sales_agg
	GROUP BY product_id 
),
price_stats AS (
	SELECT
		percentile_cont(0.75) WITHIN GROUP (ORDER BY sale_price) AS p75
	FROM product_price
),
inv_agg AS (
	SELECT 
		inv.product_id,
		SUM(CASE WHEN inv.snapshot_type = 'start' THEN inv.on_hand END) AS start_inv,
		SUM(CASE WHEN inv.snapshot_type = 'end' THEN inv.on_hand END ) AS end_inv
	FROM gold.inventory_snapshot inv
	GROUP BY inv.product_id 
),
qty_agg AS (
	SELECT
		product_id,
		SUM(total_purchase_qty) AS purchase_qty,
		SUM(total_sale_qty) AS sale_qty
	FROM (
		SELECT mvp.product_id, mvp.total_purchase_qty, NULL AS total_sale_qty FROM gold.mv_purchases_agg mvp
		UNION ALL 
		SELECT mvs.product_id, NULL AS total_purchase_qty, mvs.total_sale_qty FROM gold.mv_sales_agg mvs
	) t
	GROUP BY product_id
),
shrinkage_calc AS (
	SELECT 
		pp.product_id,
		CASE 
			WHEN pp.sale_price >= ps.p75 THEN 'high_value' ELSE 'low_value' END AS product_cat,
		(ia.start_inv + qa.purchase_qty - qa.sale_qty) - ia.end_inv AS units_lost,
		ROUND(((start_inv + purchase_qty - sale_qty) - end_inv) * sale_price, 2) AS monetary_value,		
		((ia.start_inv + qa.purchase_qty - qa.sale_qty) - ia.end_inv)
		/ NULLIF((ia.start_inv + qa.purchase_qty - qa.sale_qty), 0) * 100 AS loss_rate
	FROM product_price pp
	CROSS JOIN price_stats ps
	JOIN inv_agg ia ON pp.product_id = ia.product_id 
	JOIN qty_agg qa ON pp.product_id = qa.product_id
)
SELECT 
	product_cat,
    COUNT(CASE WHEN units_lost > 0 THEN 1 END) AS units_lost,
    SUM(monetary_value) monetary_value,
	ROUND(AVG(loss_rate), 2) AS avg_loss_rate
FROM shrinkage_calc
WHERE units_lost > 0
GROUP BY product_cat
;
-- OUTPUT:
/*
product_cat|units_lost|monetary_value|avg_loss_rate
-----------+----------+--------------+-------------
high_value |        17|      31252.49|        24.41
low_value  |       103|     233514.22|        22.03
*/