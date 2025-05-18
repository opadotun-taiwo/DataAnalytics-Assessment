SELECT 
    ss.owner_id,
    CONCAT(uc.first_name, ' ', uc.last_name) AS name,
    TIMESTAMPDIFF(MONTH, uc.date_joined, CURDATE()) AS tenure_months,
    COUNT(ss.transaction_reference) AS total_transactions,
    ROUND(
        (COUNT(ss.transaction_reference) / NULLIF(TIMESTAMPDIFF(MONTH, uc.date_joined, CURDATE()), 0)) 
        * 12 * ((SUM(ss.confirmed_amount) / NULLIF(COUNT(ss.transaction_reference), 0)) * 0.001), 
        2
    ) AS estimated_clv -- strictly using average transaction value to get the avg_profit_per_transaction
FROM adashi_staging.savings_savingsaccount ss 
JOIN adashi_staging.users_customuser uc 
    ON ss.owner_id = uc.id 
GROUP BY ss.owner_id, uc.first_name, uc.last_name
ORDER BY estimated_clv DESC;
