/* 
=============================================================================================== 
Product Report 
===============================================================================================
Purpose: To generate a report of products with their details. 
Highlights: - Retrieves product information from the Products table. 
- Displays product name, price, and category. 
- Segments products by revenue to identify top performers, mid, and low performers. 
- Aggregates product level metrics: 
  (total orders, total sales, total quantity sold, total customers (unique), lifespan). 
- Calculates valuable KPIs: 
- Average Order Revenue(AOV): Total Sales / Total Orders 
- Average monthly revenue: Total Sales / Lifespan (in months) 
- recency (months since last purchase) 
============================================================================================== 
*/
CREATE OR ALTER VIEW gold.vw_product_report AS
WITH product_sales AS
(
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        p.product_cost,
        COUNT(DISTINCT s.order_number) AS total_orders,
        SUM(s.sales_amount) AS total_sales,
        SUM(s.sales_quantity) AS total_quantity,
        COUNT(DISTINCT c.customer_id) AS total_customers,
        DATEDIFF(
            MONTH,
            MIN(s.order_date),
            MAX(s.order_date)
        ) AS lifespan_months,
        MAX(s.order_date) AS last_order_date
    FROM gold.dim_products p
    INNER JOIN gold.fact_sales s
        ON p.product_key = s.product_key
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY
        p.product_id,
        p.product_name,
        p.category,
        p.product_cost
)

SELECT
    product_id,
    product_name,
    category,
    product_cost,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    lifespan_months,
    CASE
        WHEN total_sales >= 8000 THEN 'Top Performer'
        WHEN total_sales >= 1000 THEN 'Mid Performer'
        ELSE 'Poor Performer'
    END AS performance_segment,
    -- AOV
    CASE
        WHEN total_orders > 0
        THEN ROUND (CAST(total_sales AS FLOAT) / total_orders, 2)
        ELSE 0
    END AS average_order_value,
    -- Revenue per unit
    CASE
        WHEN total_quantity > 0
        THEN ROUND (CAST(total_sales AS FLOAT) / total_quantity, 2)
        ELSE 0
    END AS average_revenue_per_unit,
    -- Monthly revenue
    CASE
        WHEN lifespan_months > 0
        THEN ROUND (CAST(total_sales AS FLOAT) / lifespan_months, 2)
        ELSE total_sales
    END AS average_monthly_revenue,
    -- Recency
    DATEDIFF(
        MONTH,
        last_order_date,
        GETDATE()
    ) AS recency_months
FROM product_sales;
