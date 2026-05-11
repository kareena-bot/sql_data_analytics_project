
# Customer Analytics Report (SQL Data Warehouse Project)

## Overview
This project builds a customer-level analytics view using a star schema data warehouse. It combines customer and sales data to generate key performance indicators (KPIs) for customer behavior, value, and segmentation.

The goal is to understand customer spending patterns, engagement, and lifecycle value.

---

## Data Sources
- `gold.dim_customers` (customer dimension table)
- `gold.fact_sales` (sales fact table)

---

## Key Features

### Customer-Level Metrics
- Total orders per customer
- Total spending
- Total products purchased
- Number of distinct products bought
- Customer lifespan (months active)
- Recency (months since last purchase)

---

### Customer Segmentation
Customers are grouped into segments:

- **VIP Customers**
  - Lifespan ≥ 12 months AND total spending > 5000

- **Regular Customers**
  - Lifespan ≥ 12 months AND total spending ≤ 5000

- **New Customers**
  - Lifespan < 12 months

---

### Age Segmentation
Customers are grouped into age bands:
- Under 20
- 20–29
- 30–39
- 40–49
- 50+

---

## KPIs Calculated

- **Average Order Value (AOV)**  
  Total Spending / Total Orders

- **Average Spending per Month**  
  Total Spending / Customer Lifespan (months)

- **Recency**  
  Months since last purchase

---

## Output
A SQL view:
`gold.vw_customer_report`

This view is ready for:
- Power BI dashboards
- Tableau analysis
- Customer segmentation reporting

---

## Skills Demonstrated
- SQL (CTEs, joins, aggregation)
- Data modelling (star schema)
- Customer analytics
- KPI design
- Business segmentation logic
- Data warehouse reporting layer (gold layer)

---

## Notes
This project is part of my learning journey in data analytics and data engineering, focused on building real-world reporting layers and business-ready datasets.
