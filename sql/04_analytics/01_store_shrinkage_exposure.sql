/*=====================================================================================
-- BUSINESS QUESTION: Which stores represent the highest financial exposure due to inventory shrinkage?	

-- PURPOSE: Identify stores with the largest monetary losses from shrinkage, both in terms of 
-- 			revenue and cost, to prioritize operational attention, loss prevention, and strategic focus.

-- DATA & SCOPE:
--   - Purchase and sales data from materialized views (mv_purchases_agg, mv_sales_agg)
--   - Inventory snapshots (start and end of period) per store
--   - Only stores with recorded purchases, sales, and inventory snapshots are included

-- APPROACH:
--   1. Aggregate inventory (start & end) and total purchased and sold quantities per store
--   2. Calculate units_lost, loss_rate, shrinkage revenue and cost values
--   3. Filter stores with positive shrinkage and apply revenue-loss percentiles (96th and 91st)
--      to dynamically categorize stores into priority levels (Critical, High Impact, Monitor)

-- ASSUMPTIONS & NOTES:
--   - Only positive shrinkage considered (actual loss)
--   - Dual-valuation used to represent total financial exposure (lost revenue and lost capital)
--   - Percentile thresholds chosen to categorize stores into priority tiers

-- OUTPUT: Prioritized list of stores with revenue and cost impact, loss_rate, and priority_level.
=====================================================================================*/
WITH store_cost AS (
    SELECT
        store_id,
        ROUND(SUM(weighted_purchase_price * total_purchase_qty) / NULLIF(SUM(total_purchase_qty), 0), 2) AS purchase_price
    FROM gold.mv_purchases_agg
    GROUP BY store_id
),
product_price AS (
    SELECT
        mvs.store_id,
        ROUND(SUM(weighted_sale_price * total_sale_qty) / NULLIF(SUM(total_sale_qty), 0), 2) AS sale_price
    FROM gold.mv_sales_agg mvs
    GROUP BY mvs.store_id
),
qty_agg AS (
    SELECT
        store_id,
        SUM(total_purchase_qty) AS purchase_qty,
        SUM(total_sale_qty)     AS sale_qty
    FROM (
        SELECT store_id, total_purchase_qty, NULL AS total_sale_qty FROM gold.mv_purchases_agg
        UNION ALL
        SELECT store_id, NULL AS total_purchase_qty, total_sale_qty FROM gold.mv_sales_agg
    ) t
    GROUP BY store_id
),
inv_snap AS (
    SELECT
        store_id,
        SUM(CASE WHEN snapshot_type = 'start' THEN on_hand END) AS start_inv,
        SUM(CASE WHEN snapshot_type = 'end'   THEN on_hand END) AS end_inv
    FROM gold.inventory_snapshot
    GROUP BY store_id
),
shrinkage_calc AS (
    SELECT
        sc.store_id,
        (start_inv + purchase_qty - sale_qty) - end_inv                                                                           AS units_lost,
        ROUND((((start_inv + purchase_qty - sale_qty) - end_inv) / NULLIF((start_inv + purchase_qty - sale_qty), 0)) * 100, 2)    AS loss_rate,
        ROUND(((start_inv + purchase_qty - sale_qty) - end_inv) * sale_price, 2)                                                  AS revenue_loss,
        ((start_inv + purchase_qty - sale_qty) - end_inv) * purchase_price                                                        AS cost_loss
    FROM store_cost sc
    JOIN product_price pp ON sc.store_id = pp.store_id
    JOIN qty_agg       qa ON sc.store_id = qa.store_id
    JOIN inv_snap     inv ON sc.store_id = inv.store_id
),
thresholds AS (
    SELECT
        PERCENTILE_CONT(0.96) WITHIN GROUP (ORDER BY revenue_loss) AS p96,
        PERCENTILE_CONT(0.91) WITHIN GROUP (ORDER BY revenue_loss) AS p91
    FROM shrinkage_calc
    WHERE revenue_loss > 0
)
SELECT
    s.store_id,
    s.revenue_loss,
    s.cost_loss,
    s.loss_rate,
    CASE
        WHEN s.revenue_loss >= t.p96 THEN 'critical'
        WHEN s.revenue_loss >= t.p91 THEN 'high impact'
        ELSE 'monitor'
    END AS priority_level
FROM shrinkage_calc s
CROSS JOIN thresholds t
WHERE s.revenue_loss > 0
ORDER BY s.revenue_loss DESC
LIMIT 4;

-- OUTPUT:
/*
store_id|revenue_loss|cost_loss|loss_rate|priority_level
--------+------------+---------+---------+--------------
      77|    53136.97| 38996.50|     1.28|critical
      25|    34123.62| 25167.99|     1.44|critical
      63|    22023.45| 15990.30|     1.43|high impact
      47|    20152.72| 14439.32|     1.67|high impact
*/