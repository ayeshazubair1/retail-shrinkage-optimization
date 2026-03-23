/*=====================================================================================
-- BUSINESS QUESTION: Which SKUs have excess inventory (>90 days supply) tying up capital?

-- PURPOSE: Identify high-inventory SKUs to flag critical products that may require action
--          to reduce capital tied up and optimize inventory.

-- DATA & SCOPE:
--   - Sales data: 1 year (2016) of recorded sales only
--   - Inventory: Two snapshots only—beginning and end of the year—for each product at each store
--   - Products with zero sales are excluded from this analysis

-- APPROACH:
--   1. Calculate Days of Supply (DOS) = End Inventory / (Average Daily Sales)
--   2. Select SKUs with DOS > 90 days
--   3. Segment by store to prioritize critical SKUs (priority segment: A_Critical)
--   4. Optional deeper analysis by classification and price tier is included for reference

-- ASSUMPTIONS & NOTES:
--   - Purchase price is same across all stores; aggregation at product level is sufficient
--   - Percentile thresholds for segmentation were chosen after exploring full distribution

-- OUTPUT: Prioritized stores with excess inventory (DOS > 90), showing total affected SKUs,
--         weighted average days of supply, total capital tied up, and priority segmentation.
=====================================================================================*/

CREATE TEMP TABLE temp_base AS 
	WITH days AS (
	    SELECT
	        (MAX(s.sale_date) - MIN(s.sale_date)) AS sales_period_days
	    FROM gold.sales s
	),
	sales_qty AS (
	    SELECT
	    	store_id,
	        product_id,
	        SUM(total_sale_qty) AS sale_qty,
	        classification
	    FROM gold.mv_sales_agg
	    GROUP BY store_id, product_id, classification
	),
	inv_end AS (
	    SELECT
	    	store_id,
	        product_id,
	        SUM(CASE WHEN snapshot_type = 'end' THEN on_hand END) AS end_inv
	    FROM gold.inventory_snapshot
	    GROUP BY store_id, product_id
	),
	product_cost AS (
	    SELECT
	        mvp.product_id,
	        ROUND(AVG(weighted_purchase_price), 2) AS purchase_price				
	    FROM gold.mv_purchases_agg mvp
	    GROUP BY mvp.product_id 
	),
	days_of_inv AS (
	    SELECT
	    	s.store_id,
	        s.product_id,
	        end_inv,
	        ROUND(i.end_inv / NULLIF((s.sale_qty / d.sales_period_days), 0), 2) AS dos,
	        (i.end_inv * pp.purchase_price) AS monetary_value,
	        pp.purchase_price,
	        s.classification
	    FROM sales_qty s
		JOIN inv_end i ON s.store_id = i.store_id AND s.product_id = i.product_id
	    JOIN product_cost pp ON s.product_id = pp.product_id
	    CROSS JOIN days d
	    WHERE s.sale_qty > 0
	)
	SELECT * 
	FROM days_of_inv
	WHERE dos > 90
;
--=====================================================================================

-- Segmentation by store
WITH store_agg AS (
	SELECT
		store_id,
		COUNT(product_id) AS total_products,
        ROUND(SUM(dos * end_inv) / NULLIF(SUM(end_inv), 0), 2) AS weighted_avg_dos,
		SUM(monetary_value) AS total_value
	FROM temp_base
	GROUP BY store_id
),
pcnt_cont AS (	
	SELECT
	    percentile_cont(0.75) WITHIN GROUP (ORDER BY weighted_avg_dos) AS p75_dos,
	    percentile_cont(0.75) WITHIN GROUP (ORDER BY total_value) AS p75_value  
	FROM store_agg
),
segmentation AS (
	SELECT
		store_id,
		total_products,
		weighted_avg_dos,
		total_value,
		CASE 
	        WHEN weighted_avg_dos >= p75_dos AND total_value >= p75_value THEN 'A_Critical'
	        WHEN weighted_avg_dos >= p75_dos AND total_value < p75_value THEN 'B_SlowMoving'
	        WHEN weighted_avg_dos < p75_dos AND total_value >= p75_value THEN 'C_HighVolume'
	        ELSE 'D_Normal'
	    END AS priority_segment
	FROM store_agg 
	CROSS JOIN pcnt_cont
	ORDER BY 
		CASE 
	        WHEN weighted_avg_dos >= p75_dos AND total_value >= p75_value THEN 1
	        WHEN weighted_avg_dos < p75_dos AND total_value >= p75_value THEN 2
	        WHEN weighted_avg_dos >= p75_dos AND total_value < p75_value THEN 3
	        ELSE 4
	    END, total_value DESC 
)
SELECT *
FROM segmentation
WHERE priority_segment <> 'D_Normal'
	AND priority_segment <> 'B_SlowMoving'
;
-- OUTPUT:
/*
store_id|total_products|weighted_avg_dos|total_value|priority_segment
--------+--------------+----------------+-----------+----------------
      77|          4082|         1153.51| 1989294.39|A_Critical      
      26|          2329|          716.29| 1107011.98|A_Critical      
      49|          2018|          721.93| 1105203.58|A_Critical      
      64|          2975|         1802.38|  950831.18|A_Critical      
      40|          2235|          775.41|  938253.04|A_Critical      
      33|          1335|          642.93|  574890.44|A_Critical      
      41|          1148|          592.39|  567962.50|A_Critical      
      51|          1638|          583.54|  487036.33|A_Critical      
       3|          1848|          617.96|  469275.48|A_Critical      
      43|          1704|          570.21|  463424.44|A_Critical      
      25|          3443|          511.78| 1308773.84|C_HighVolume    
      50|          2526|          509.07|  875723.44|C_HighVolume    
      45|          1519|          554.58|  830545.09|C_HighVolume    
      27|          1732|          489.49|  829576.81|C_HighVolume    
      47|          2474|          427.31|  772732.95|C_HighVolume    
      36|          2168|          463.84|  727987.84|C_HighVolume    
      63|          2437|          523.74|  718573.63|C_HighVolume    
      14|          1782|          405.26|  551235.21|C_HighVolume    
      68|          1810|          544.57|  528078.58|C_HighVolume    
      58|          1540|          432.94|  466522.11|C_HighVolume    
*/