WITH monthly_txns AS (
    SELECT
        ss.owner_id,
        DATE_FORMAT(ss.transaction_date, '%Y-%m') AS ym,
        COUNT(*) AS transactions_in_month
    FROM adashi_staging.savings_savingsaccount ss
    GROUP BY ss.owner_id, DATE_FORMAT(ss.transaction_date, '%Y-%m')
), -- get the monthly transaction using mysql dialet for date_format
avg_txns_per_customer AS (
    SELECT
        owner_id,
        AVG(transactions_in_month) AS avg_transactions_per_month
    FROM monthly_txns
    GROUP BY owner_id
),-- group the transactions by customer to get what each customer is doing per month
categorized_customers AS (
    SELECT
        owner_id,
        avg_transactions_per_month,
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM avg_txns_per_customer
) -- categorize customer based on avg_transaction_per_month
SELECT
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category; -- show result
