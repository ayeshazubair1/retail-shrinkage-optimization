# Retail Shrinkage & Inventory Optimization Analysis — Bibitor LLC

## Business Context
Bibitor LLC is a retail wine and spirits company operating ~80 stores across the fictional state of Lincoln. Annual sales range between \$420–450M, with COGS around \$300–350M. Despite strong revenue, store-level shrinkage (unexplained inventory loss) was increasing, reducing profit margins and creating stock imbalances: some stores were overstocked, while others frequently ran out of top-selling products.

> **The Challenge:** Identify where inventory is disappearing, what's tying up capital, and which operational failures are driving both issues.

## 🎯 Executive Summary
Despite strong revenues, Bibitor's margins are being quietly eroded from two directions:   
- $199K in direct annual shrinkage losses
- $28M in capital tied up in slow-moving inventory

65% of all shrinkage is localized in four stores — notably Store 77 and Store 25 — which also carry the highest excess inventory levels. Vendor fulfillment inaccuracies compound the problem, with William Grant & Sons Inc alone accounting for a 35K-unit delivery variance.   
Prioritizing targeted audits at high-risk stores and enforcing vendor compliance controls will provide the fastest path to reducing losses, improving inventory turnover, and releasing trapped capital.        
**View Dashboard** [here.](https://public.tableau.com/app/profile/ayeshazubair/viz/RetailShrinkageInventoryAnalysisBibitorLLC/bibitor_dashboard)

## Key Findings & Business Implications

#### 1. Shrinkage Is Highly Concentrated: Four Stores Drive Nearly Two-Thirds of Total Loss
Four locations — Stores 77, 25, 63, and 47 — account for approximately **$129K**, or 65%, of total annual shrinkage ($200K). Combined exposure breaks down into $94K in direct cost and $35K in lost margin, confirming that financial impact extends beyond inventory write-offs. Store 77 is the highest-risk location at $53K in exposure, likely amplified by its large SKU assortment (7,344 SKUs).

**Business Implication:** Shrinkage is concentrated, not systemic. Because unrealized margin exceeds direct write-offs, the true financial impact is understated in accounting records — and the concentration means leadership can target a small set of stores rather than applying broad, inefficient interventions across the network.

<img src="docs/images/01_store_shrinkage.png" width="350" alt="Vertical bar chart showing financial loss from shrinkage">

#### 2. Operational Leakage Dominates: Low-Value Items Drive 88% of Shrinkage Value
While high-value products show a slightly higher average loss rate, low-value items account for **88%** of total shrinkage value ($233K of $264K) — driven by volume, not unit price.

**Business Implication:** This pattern points to operational failures — receiving errors, miscounts, breakage, and recording gaps — as the primary loss drivers. Interventions focused solely on high-value theft prevention would address less than 12% of total exposure. Broader process controls are required to materially reduce shrinkage.

<img src="docs/images/02_value_tier.png" width="350" alt="Vertical bar chart showing monetary loss by product category">

#### 3. Capital Inefficiency Represents the Largest Structural Risk: $28M Locked in Slow-Moving Inventory
Across the network, 8,198 SKUs exceed 90 days of supply, tying up approximately **$28M** in working capital. Exposure is highly concentrated — four stores (77, 26, 49, and 25) alone account for ~$5.5M, with Store 77 as the single largest contributor at nearly $2M in slow-moving stock.   
Liquidity risk is most severe in Stores 64, 77, 40, and 49, where inventory-weighted average days of supply exceed 700 days, indicating prolonged stagnation.

**Business Implication:** Inventory inefficiency poses a larger structural risk than shrinkage. At an 8% cost of capital, excess stock generates ~$2.24M in annual opportunity cost — and unlike shrinkage, this exposure compounds over time as holding periods increase damage and obsolescence risk.

<img src="docs/images/03_excess_inventory.png" width="350" alt="Horizontal bar chart showing stores with most capital tied up in excess inventory">

#### 4. Vendor Delivery Inaccuracies Create Systemic Stock Imbalances
Inventory variance is concentrated among specific vendors rather than occurring randomly. William Grant & Sons Inc shows cumulative under-deliveries exceeding 35,000 units, while Alisa Carr Beverages over-delivered by approximately 65% relative to ordered quantities. These deviations are consistent across multiple products, indicating persistent fulfillment inaccuracies.

**Business Implication:** Vendor delivery reliability is a direct driver of inventory imbalance. Under-delivery creates stockouts and lost sales, while over-delivery increases capital lock-up. Because variance is concentrated among a small number of suppliers, this represents a manageable counterparty risk rather than a systemic supply-chain failure.

<img src="docs/images/04_vendor_variance.png" width="400" alt="Diverging bar chart showing vendor fulfillment accuracy">

#### 5. Geographic Patterns Reveal Distinct Operational Failure Modes
Losses cluster geographically. Mountmend (Store 77) and Paentmarwy (Store 25) together account for over **\$64K** in shrinkage. In contrast, locations such as Eanverness (Store 49) and Pitmerden (Store 40) exhibit significant overstock relative to recorded deliveries.

**Business Implication:** Operational failures are not uniform across the network. Loss-heavy cities indicate breakdowns in inventory control or security, while overstock-heavy locations suggest receiving and recording failures. This heterogeneity invalidates one-size-fits-all solutions and highlights the need for differentiated operational diagnosis.

<img src="docs/images/05_location_risk.png" width="400" alt="Diverging bar chart showing financial discrepancies">

## Recommended Action Plan

#### 1. Stabilize Inventory Where Risk Concentrates
##### Phase 1.1 - High-Risk Stores (Immediate)
**Target Stores:** 77, 25, 26, 49    
These locations are repeatedly flagged across shrinkage, excess days of supply, and overstock indicators — signaling compounding risk, not isolated variance. Addressing them first delivers the highest return by reducing margin erosion and releasing tied-up capital.

* Perform focused inventory reconciliations to identify root discrepancies
* Tighten receiving and stock movement controls for high-volume SKUs
* Introduce short-cycle counts for slow-moving and variance-prone items
* Temporarily restrict replenishment for SKUs exceeding 90 days of supply

##### Phase 1.2 - Moderate-Risk Stores (Targeted Controls)
**Target Stores:** 63, 47, 50, 45  
These stores show elevated risk in a single dimension — shrinkage or excess inventory — but no compounding failure patterns yet. Early controls reduce the likelihood of escalation into Phase 1 territory.

* Apply inventory controls validated in Phase 1
* Monitor shrinkage and days-of-supply trends on a rolling basis
* Escalate stores showing worsening indicators to Phase 1 protocols

#### 2.  Fix Process Leakage in Low-Value Products
**Target Category:** Low-value products  
Low-value products account for the highest unit loss volume and contribute approximately **$233K** in shrinkage — making them the dominant driver of total shrinkage by scale, not rate.

* Strengthen receiving and quantity verification for low-value items
* Increase cycle count frequency for discrepancy-prone SKUs
* Standardize shelf-replenishment practices to reduce breakage and misplacement

#### 3. Enforce Vendor Delivery Accountability
**Target Area:** Vendors with persistent over-delivery and under-delivery patterns  
Inventory variance is concentrated among a small number of vendors. Under-delivery drives stockouts; over-delivery creates excess inventory and capital lock-up. Both are addressable without broad supply-chain disruption.

* Introduce vendor-level delivery accuracy tracking (ordered vs. received)
* Flag vendors with repeated deviations beyond acceptable tolerance
* Require enhanced receiving verification for high-variance vendors

## Methodology & Analytical Approach

**1. Performance Optimization:** To handle high-volume tables (12M+ sales records), Materialized Views and B-Tree Indexing were implemented on primary and foreign keys — significantly reducing query execution time by pre-aggregating core metrics and improving data retrieval efficiency.   
**2. Code Modularization:** CTEs were used to keep the analytical pipeline modular, readable, and maintainable — allowing complex multi-step calculations to be audited easily.   
**3. Weighted Valuation:** Weighted Averages were preferred over naive averages for sale and purchase prices, ensuring high-volume transactions carry appropriate mathematical weight and preventing low-volume outliers from skewing financial results.   
**4. Core Shrinkage Framework:** A three-pillar calculation was standardized across every business question for consistency:
- **Unit Loss:** Physical inventory discrepancy.
- **Monetary Impact:** Total dollar-value exposure.
- **Percentage Impact:** Loss rate relative to total volume or value    

**5. Data-Driven Threshold:** In the absence of predefined industry benchmarks, `PERCENTILE_CONT` was used to perform a distribution analysis and establish risk thresholds from the data itself.   
**6. Risk Categorization:** Final segmentation (Critical vs. High-Impact) was derived by testing multiple percentiles (P75, P91, P96) to identify the elbow point — the threshold where financial risk and exposure significantly accelerate.   

## Operational Risk & Performance Indicators

| Metric 						| Value 					| Business Context 	                                    |					
|:--------						|:-------					|:------------------								    |
| **Total Shrinkage Loss** 		| $199K 					| Annual revenue impact across 41 stores 			    |
| **Capital Trapped** 			| $28M			 			| Total value of inventory exceeding the 90-day supply threshold 					    |
| **Worst Performing Store**	| Store 77 		| Accounts for $53K in loss; ranks 1st in shrinkage despite 6th in sales   |
| **Top Vendor Issue**			| 35.9K 	| William Grant & Sons Inc — highest under-delivery variance across all vendors 			    |
| **Loss Concentration**		| 65%    	| $129K of total losses are localized within just 4 key stores 			    |
| **Product Pattern** 			| 88%  | Loss is dominated by low-value items, suggesting process errors over theft. 					|

## 🛠️ Tech Stack & Data Architecture

**Tools:** PostgreSQL • DBeaver • Tableau  
**Architecture:** Raw → Clean → Gold (medallion approach)
**Data Flow:**
```
Raw CSV Files
    ↓
Clean Layer (Views: deduplication, validation, type casting)
    ↓
Gold Schema (Star schema with materialized aggregations)
```
**Why This Architecture:** The Gold schema ensures consistent business definitions across all downstream analysis—mimicking the semantic layer approach used by enterprise retail analytics teams.  
Detailed technical documentation [here.](data_catalog.md)   
Download [Dataset](https://www.hubae.org/datvironment/bibitor/)  

## Future Analysis Opportunities
**1-** Incorporate monthly sales trends to calculate dynamic safety stock levels, replacing the fixed 90-day threshold to better manage seasonal demand and holiday volatility.

**2-** Integrate store-level labor hours and employee turnover data to identify whether high shrinkage rates in specific locations correlate with staffing shortages or gaps in inventory receiving protocols.

**3-** Investigate the 35K-unit vendor discrepancy using delivery logs and warehouse records to determine if the variance stems from paperwork errors, shipping issues, or physical loss.

## ⚠️ Limitations & Assumptions

**1. Synthetic Dataset:** This project uses a fictional dataset, so operational details like store layouts, staffing levels, cycle-count frequencies, or security logs are unavailable for root-cause analysis.   
**2. Temporal Granularity:** Inventory data is limited to annual snapshots (Start-of-Year and End-of-Year), preventing analysis of monthly trends, quarterly fluctuations, or specific out-of-stock periods.   
**3. Standardized Sales Velocity:** The Days of Supply (DOS) calculation assumes a steady sales pace year-round — it does not account for holiday spikes or seasonality.   
**4. Data-Driven Benchmarks:** The 90-day supply threshold and percentile benchmarks were derived from internal data distribution analysis, serving as logical estimates for business risk where company-defined KPIs were unavailable.   
**5. Data Scope:** Only products with recorded sales and inventory movement are included.   

## 📁 Project Structure
```
bibitor_llc/
├── docs
│   ├── images
│   ├── results
│   ├── 01_schema_layers.svg
│   └── 02_ERD_bibitor_llc.svg
├── sql
│   ├── 01_ddl
│   ├── 02_load
│   ├── 03_test
│   ├── 04_analytics
│   └── db_init.sql
├── License.txt
├── README.md
├── Retail Shrinkage & Inventory Analysis | Bibitor LLC.twb
└── data_catalog.md
```

### 📬 Feel Free to Connect
[![Gmail](https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:ayeshazubair.contact@gmail.com) [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ayeshazubair-az/) [![Portfolio](https://img.shields.io/badge/Portfolio-709fa5?style=for-the-badge&logo=google-chrome&logoColor=white)](https://ayeshazubair1.github.io/portfolio/projects/retail-shrinkage-analysis.html) [![Tableau](https://img.shields.io/badge/Tableau-E97627?style=for-the-badge&logo=tableau&logoColor=white)](https://public.tableau.com/app/profile/ayeshazubair/vizzes)

### 📄 License
This project is licensed under the MIT License. See the [License](License.txt) file for details.