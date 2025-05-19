SELECT 
    ss.owner_id, 
    CONCAT(uc.first_name, ' ', uc.last_name) AS name, 
    COUNT(DISTINCT CASE WHEN pp.is_regular_savings = 1 THEN ss.plan_id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN pp.is_a_fund = 1 THEN ss.plan_id END) AS investment_count,
    SUM(ss.confirmed_amount) AS total_deposits
FROM adashi_staging.savings_savingsaccount ss 
JOIN adashi_staging.users_customuser uc 
    ON ss.owner_id = uc.id 
JOIN adashi_staging.plans_plan pp 
    ON ss.plan_id = pp.id -- using a where clause would retrun no data 
GROUP BY 
    ss.owner_id, 
    name
HAVING 
    SUM(ss.confirmed_amount) > 0 -- make sure it is an account with deposit
ORDER BY 
    total_deposits DESC;
