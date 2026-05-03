/*=====================================================================================
-- BUSINESS QUESTION: Do inventory discrepancies show systematic patterns by location,
					  identifying stores with significant overstock or shrinkage?
-- PURPOSE: Explore whether certain cities or locations exhibit consistent overstocking 
--          or shrinkage patterns that could indicate operational issues.

-- DATA & SCOPE:
--   - Store-level data, including city information
--   - Inventory snapshots (start and end) aggregated at the store level
	 - Purchases and sales aggregated to the store level
--   - Analysis covers all stores with available inventory and sales data

-- APPROACH:
--   1. Compute weighted average purchase price per store to value inventory discrepancies
--   2. Aggregate inventory (start/end) and total purchased/sold quantities per store
--   3. Compute units_lost, loss_rate, and cost_loss per store

-- ASSUMPTIONS & NOTES:
--   - This is an exploratory analysis; limited store density per city may affect statistical stability
--   - Only store-product combinations with complete data included
--   - cost_loss calculated using weighted purchase price
--   - Positive and negative shrinkage captured to see both overstock and losses

-- OUTPUT: Store-level ranking showing top loss and overstock locations by cost_loss,
--		   including units_lost, loss_rate, risk_rank, and risk_type.
		  
=====================================================================================*/

WITH base AS (
	SELECT 
		s.store_id,
		s.city,
		ROUND(SUM((mvp.weighted_purchase_price * mvp.total_purchase_qty)) / NULLIF(SUM(mvp.total_purchase_qty), 0), 2) AS weighted_purchase_price
	FROM gold.stores s
	LEFT JOIN gold.mv_purchases_agg  mvp ON s.store_id = mvp.store_id 
	GROUP BY s.store_id, city
),
inv_snap AS (
	SELECT
		store_id,
		SUM(CASE WHEN snapshot_type = 'start' THEN on_hand END) AS start_inv,
		SUM(CASE WHEN snapshot_type = 'end'   THEN on_hand END) AS end_inv
	FROM gold.inventory_snapshot 
	GROUP BY store_id
),
qty_agg AS (
	SELECT 
		store_id,
		SUM(total_purchase_qty) AS purchase_qty,
		SUM(total_sale_qty)	    AS sale_qty
	FROM (
		SELECT store_id, total_purchase_qty, NULL AS total_sale_qty FROM gold.mv_purchases_agg 
		UNION ALL
		SELECT store_id, NULL AS total_purchase_qty, total_sale_qty FROM gold.mv_sales_agg 
	) t
	GROUP BY store_id
),
shrinkage_calc AS (
	SELECT 
		b.store_id,
		city,
		(start_inv + purchase_qty - sale_qty) - end_inv AS units_lost,
		ROUND((((start_inv + purchase_qty - sale_qty) - end_inv) / NULLIF((start_inv + purchase_qty - sale_qty), 0)) * 100, 2) AS loss_rate,
		((start_inv + purchase_qty - sale_qty) - end_inv) * weighted_purchase_price AS cost_loss
	FROM base b
	JOIN inv_snap inv ON b.store_id = inv.store_id 
	JOIN qty_agg qa   ON b.store_id = qa.store_id  
),
ranked AS (
	SELECT 
		store_id,
		city,
		loss_rate,
		cost_loss,
		DENSE_RANK() OVER(ORDER BY cost_loss DESC) AS loss_rank,
		DENSE_RANK() OVER(ORDER BY cost_loss ASC)  AS overstock_rank,
		CASE 
			WHEN cost_loss > 0 THEN 'loss'
			WHEN cost_loss < 0 THEN 'overstock'
		END AS risk_type
	FROM shrinkage_calc 
	WHERE cost_loss IS NOT NULL
		AND cost_loss <> 0
)
SELECT
	store_id,
	city,
	cost_loss,
	loss_rate,
	CASE 
		WHEN loss_rank <= 3 	THEN loss_rank
		WHEN overstock_rank <=3 THEN overstock_rank
	END AS risk_rank,
	risk_type 
FROM ranked
WHERE loss_rank <= 3 OR overstock_rank <= 3
ORDER BY risk_type, risk_rank
;

-- OUTPUT:
/*
store_id|city      |cost_loss|loss_rate|risk_rank|risk_type
--------+----------+---------+---------+---------+---------
      77|Mountmend | 38996.50|     1.28|        1|loss     
      25|Paentmarwy| 25167.99|     1.44|        2|loss     
      63|Larnwick  | 15990.30|     1.43|        3|loss     
      49|Eanverness| -6217.64|    -0.35|        1|overstock
      26|Mountmend | -4580.42|    -0.30|        2|overstock
      40|Pitmerden | -3444.12|    -0.22|        3|overstock
*/