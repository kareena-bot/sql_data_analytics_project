/*
=======================================================================
Customer Report
=======================================================================
Purpose
This report provides insights into customer demographics and purchasing behavior. 
It combines data from the CRM and ERP systems to give a comprehensive view of customers, their purchases, and associated product information.
Highlights
1. Gathers essential fields such as customer names, age and purchasing history.
2. Segments customers into VIP, Regular, and New categories based on their spending and history.
3. Aggregates customer level metrics
- Total spending
- Average order value
- Total number of orders
- lifespan in months
- total products
4. Calculates valuable KPIs
 - Average spending per month
 - Average spending per order
 - Recency of last purchase
=======================================================================
*/
CREATE OR ALTER VIEW gold.vw_customer_report AS
WITH base_query AS
/*---------------------------------------------------------------------
Base Query: Gather essential columns from tables.
-----------------------------------------------------------------------
*/
(
SELECT 
	s.order_number,
	s.sales_amount,
	s.sales_quantity,
	s.order_date,
	s.product_key,
	c.customer_key,
	c.customer_number,
	CONCAT (c.first_name, ' ', c.last_name) AS customer_name,
	DATEDIFF (year, c.birthdate, GETDATE()) AS age
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales s
ON c.customer_key = s.customer_key
WHERE s.order_date IS NOT NULL
),
customer_aggregates AS
/*---------------------------------------------------------------------
Customer Aggregates: Calculate customer-level metrics.
-----------------------------------------------------------------------
*/
(
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT (DISTINCT order_number) AS total_orders,
	SUM (sales_amount) AS total_spending,
	SUM (sales_quantity) AS total_products,
	COUNT (DISTINCT product_key) AS distinct_products,
	MAX (order_date) AS last_order_date,
	DATEDIFF (month, MIN (order_date), MAX (order_date)) AS lifespan_months
FROM base_query
GROUP BY 
customer_key,
customer_number,
customer_name,
age
)
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group,
	CASE 
		WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'VIP'
		WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular Customer'
		WHEN lifespan_months < 12 THEN 'New Customer'
		ELSE 'Unknown Segment'
	END AS customer_segment,
	DATEDIFF (month, last_order_date, GETDATE()) AS recency_months,
	total_orders,
	total_spending,
	total_products,
	distinct_products,
	lifespan_months,
	-- KPI - Compute Average Value per Order (AVO) = Total Spending / Total Orders
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_spending/total_orders
	END AS avg_order_value,
	--Compute average Spending per Month (ASM) = Total Spending / Lifespan in Months
	CASE 
		WHEN lifespan_months = 0 THEN total_spending
		ELSE total_spending/lifespan_months
		END AS avg_spending_per_month
FROM customer_aggregates;
