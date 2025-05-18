# DataAnalytics-Assessment
---

## Question 1 – High-Value Customers with Multiple Products

###  Scenario
The business team is looking to identify **high-value customers** who are engaging with **multiple products**, specifically those with **at least one savings plan** and **at least one investment plan**. This is a key opportunity for **cross-selling**.

### Objective
Write a query to:
- Identify customers who have both a funded savings and a funded investment plan.
- Display each customer’s total number of savings and investment accounts.
- Show the total amount deposited across all their accounts.
- Sort the result by `total_deposits` in descending order.

### Tables Involved
- `users_customuser` – Contains user information.
- `savings_savingsaccount` – Contains transaction and account-level details.
- `plans_plan` – Identifies whether a plan is savings or investment.

---

### Approach

```sql
SELECT 
    ss.owner_id,
    CONCAT(uc.first_name, ' ', uc.last_name) AS name,
    SUM(CASE WHEN pp.is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,
    SUM(CASE WHEN pp.is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count,
    SUM(ss.confirmed_amount) AS total_deposits
FROM adashi_staging.savings_savingsaccount ss
JOIN adashi_staging.users_customuser uc 
    ON ss.owner_id = uc.id
JOIN adashi_staging.plans_plan pp 
    ON ss.plan_id = pp.id
GROUP BY 
    ss.owner_id, 
    name
HAVING 
    savings_count > 0 
    AND investment_count > 0 
    AND total_deposits > 0
ORDER BY 
    total_deposits DESC;

##  Challenges Faced

One major challenge was **data structure constraints**:

###  Why this doesn't work:

```sql
WHERE pp.is_regular_savings = 1 AND pp.is_a_fund = 1

This condition tries to filter for a single plan that is both a savings and an investment account. This is logically impossible because savings and investment plans are mutually exclusive—each plan is either one or the other, not both.

Correct approach:
Use aggregations and conditional counting across multiple rows per user to count the presence of each type of plan. Then, use a HAVING clause to filter only customers that have both.



## 2. Transaction Frequency Analysis

### ✅ Scenario

The finance team needed a segmentation of users based on how frequently they perform transactions. This helps in understanding customer behavior and tailoring engagement strategies.

---

### 🧠 Task

Calculate the **average number of transactions per customer per month** and categorize them as:

- **High Frequency** (≥10 transactions/month)  
- **Medium Frequency** (3–9 transactions/month)  
- **Low Frequency** (≤2 transactions/month)  

---

### 📊 Tables Used

- `users_customuser`
- `savings_savingsaccount`

---

### 💡 My Approach

To solve this, I broke down the process into 3 key steps using Common Table Expressions (CTEs):

1. **monthly_txns**  
   Get the number of transactions per customer per month using `DATE_FORMAT` (MySQL dialect) to extract the month and year.

2. **avg_txns_per_customer**  
   Calculate the average transactions per month for each user.

3. **categorized_customers**  
   Use a `CASE` statement to categorize each user based on their average monthly transaction volume.

---

### ✅ Final Query

```sql
WITH monthly_txns AS (
    SELECT
        ss.owner_id,
        DATE_FORMAT(ss.transaction_date, '%Y-%m') AS ym,
        COUNT(*) AS transactions_in_month
    FROM adashi_staging.savings_savingsaccount ss
    GROUP BY 
        ss.owner_id, 
        DATE_FORMAT(ss.transaction_date, '%Y-%m')
), -- get the monthly transactions per customer

avg_txns_per_customer AS (
    SELECT
        owner_id,
        AVG(transactions_in_month) AS avg_transactions_per_month
    FROM monthly_txns
    GROUP BY 
        owner_id
), -- compute the average per customer

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
) -- assign frequency category

SELECT
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category;

### ⚠️ Challenge Faced

Initially, I used `TO_CHAR()` to extract the month and year, which works in **PostgreSQL**. However, the database engine used here is **MySQL**, which led to compatibility issues.

❌ PostgreSQL-only approach:

```sql
TO_CHAR(ss.transaction_date, 'YYYY-MM')



