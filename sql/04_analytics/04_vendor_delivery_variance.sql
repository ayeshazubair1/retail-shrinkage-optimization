/*=====================================================================================
-- BUSINESS QUESTION: Which vendors consistently deliver inaccurate quantities, either
--                    under-delivering or over-delivering?

-- PURPOSE: Identify vendors whose delivered quantities deviate significantly from recorded
--          purchase orders, highlighting potential operational or supply chain issues.

-- DATA & SCOPE:
--   - Purchase and sales data from materialized views (mv_purchases_agg, mv_sales_agg)
--   - Inventory snapshots (start and end of period) at product-store level
--   - Only products with recorded purchases, sales, and inventory snapshots are included
--   - Vendor-level data inferred by mapping products to vendors

-- APPROACH:
--   1. Aggregate purchased and sold quantities per product-store
--   2. Aggregate start and end inventory per product-store
--   3. Compute delivered quantity and delivery variance per product-store
--   4. Map products to vendors to calculate total delivery variance and variance percentage
--   5. Rank vendors by negative (under-delivered) and positive (over-delivered) variance

-- ASSUMPTIONS & NOTES:
--   - Only vendors with non-null delivered quantities are included
--   - Variance percentage = delivery variance / total delivered quantity * 100
--   - Both under- and over-delivered are considered to capture extremes

-- OUTPUT: Vendor-level summary showing total products, delivery variance, variance percentage,
--         vendor rank and delivery profile.
=====================================================================================*/

WITH qty_agg AS (
	SELECT 
		store_id,
		product_id,
		SUM(total_purchase_qty) AS purchase_qty,
		SUM(total_sale_qty) AS sale_qty
	FROM (
		SELECT store_id,product_id, total_purchase_qty, NULL AS total_sale_qty FROM gold.mv_purchases_agg 
		UNION ALL
		SELECT store_id, product_id, NULL AS total_purchase_qty, total_sale_qty FROM gold.mv_sales_agg 
	) t
	GROUP BY store_id, product_id
),
inv_snap AS (
	SELECT 
		store_id,
		product_id,
		SUM(CASE WHEN snapshot_type = 'start' THEN on_hand END) AS start_inv,
		SUM(CASE WHEN snapshot_type = 'end' THEN on_hand END) AS end_inv
	FROM gold.inventory_snapshot 
	GROUP BY store_id, product_id
),
deviation AS (
	SELECT
		qa.store_id,
		qa.product_id,
		start_inv - end_inv + sale_qty AS qty_delivered,
		(start_inv - end_inv + sale_qty) - purchase_qty AS variance
	FROM qty_agg qa
	JOIN inv_snap inv ON qa.store_id = inv.store_id AND 
		qa.product_id = inv.product_id 
),
vendor_map AS (
    SELECT DISTINCT store_id, product_id, vendor_id
    FROM gold.mv_purchases_agg
),
vendor_lvl AS (
    SELECT
        vm.vendor_id,
        COUNT(DISTINCT d.product_id) AS total_products,
        SUM(variance) AS variance,
        ROUND((SUM(variance) / NULLIF(SUM(qty_delivered), 0)) * 100, 2) AS variance_rate
    FROM deviation d
    JOIN vendor_map vm ON d.store_id = vm.store_id 
       AND d.product_id = vm.product_id
    GROUP BY vm.vendor_id
    HAVING 
        SUM(qty_delivered) IS NOT NULL
        AND COUNT(DISTINCT d.product_id) >= 10
),
ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY variance_rate DESC) AS over_rank,
        DENSE_RANK() OVER (ORDER BY variance_rate ASC) AS under_rank
    FROM vendor_lvl
) 
SELECT
    r.vendor_id,
    v.vendor_name,
    r.total_products,
    r.variance,
    r.variance_rate,
    CASE 
        WHEN over_rank <= 3 THEN over_rank
        WHEN under_rank <= 3 THEN under_rank
    END AS rank_no,
    CASE
        WHEN variance_rate > 0 THEN 'over delivery' ELSE 'under delivery'
    END AS delivery_profile
FROM ranked r
JOIN gold.vendors v ON r.vendor_id = v.vendor_id
WHERE over_rank <= 3 OR under_rank <= 3
ORDER BY delivery_profile, rank_no
;
-- OUTPUT:
/*
vendor_id|vendor_name             |total_products|variance|variance_rate|rank_no|delivery_profile
---------+------------------------+--------------+--------+-------------+-------+----------------
       27|alisa carr beverages    |            13|     198|        65.35|      1|over delivered   
       74|r.p.imports inc         |            37|     114|        43.02|      2|over delivered  
       25|circa wines             |            42|      38|        21.84|      3|over delivered  
       41|william grant & sons inc|            78|  -35924|       -14.44|      1|under delivered  
      113|the imported grape llc  |            20|     -96|       -13.60|      2|under delivered 
      106|sea breeze cellars llc  |            15|    -522|        -9.66|      3|under delivered  
*/