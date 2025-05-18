SELECT 
    ss.plan_id, 
    ss.owner_id,
    CASE
        WHEN pp.is_regular_savings = 1 THEN 'Savings'
        WHEN pp.is_a_fund = 1 THEN 'Investment'
        ELSE 'Unknown'
    END AS type,
    MAX(ss.transaction_date) AS last_transaction_date,
    DATEDIFF(CURDATE(), MAX(ss.transaction_date)) AS inactivity_days
FROM adashi_staging.savings_savingsaccount ss
JOIN adashi_staging.plans_plan pp 
    ON ss.plan_id = pp.id
GROUP BY 
    ss.plan_id, 
    ss.owner_id, 
    type
HAVING 
    inactivity_days > 365 
    OR last_transaction_date IS NULL
ORDER BY 
    last_transaction_date DESC;
