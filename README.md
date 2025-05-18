# DataAnalytics-Assessment

![Image Placeholder](https://i.ibb.co/zW0qwbGV/Chat-GPT-Image-May-18-2025-04-02-06-PM.png)

---

## Question 1 – High-Value Customers with Multiple Products

### Scenario
The business team seeks to identify **high-value customers** who own **at least one savings plan** and **at least one investment plan**. This group represents potential for cross-selling opportunities.

### Objective
- Identify customers with both a funded savings and investment plan.
- Display each customer’s total number of savings and investment accounts.
- Calculate the total amount deposited across all their accounts.
- Sort results by total deposit amount in descending order.

### Approach
The approach used conditional aggregation to identify customers who meet both product criteria. A `HAVING` clause was used to ensure that customers had at least one of each product type and had funded accounts.

### Challenges
An initial attempt used this condition in the `WHERE` clause:
```sql
WHERE pp.is_regular_savings = 1 AND pp.is_a_fund = 1
```
This logic was incorrect because it searched for a single plan that is both a savings and investment type, which contradicts the mutually exclusive nature of these plan types.

Resolution: The correct method was to aggregate multiple plans per user and apply conditional filters via CASE statements in the SELECT clause, followed by a HAVING clause to ensure both savings and investment presence.

## Question 2 – Transaction Frequency Analysis
Scenario
The finance team required segmentation of customers based on how often they perform transactions. This segmentation supports tailored engagement and retention strategies.

### Objective
Calculate the average number of transactions per user per month, then classify users as:

High Frequency: 10 or more transactions/month

Medium Frequency: 3 to 9 transactions/month

Low Frequency: 2 or fewer transactions/month

### Approach
The solution used three Common Table Expressions (CTEs):

monthly_txns – calculated transactions per customer per month.

avg_txns_per_customer – averaged transaction volume per customer.

categorized_customers – classified users into frequency tiers using a CASE statement.

### Challenges
Initially, TO_CHAR() was used to extract month-year values:

``` sql
TO_CHAR(ss.transaction_date, 'YYYY-MM')
```
This function is supported in PostgreSQL but not in MySQL.

Resolution: Switched to MySQL-compatible DATE_FORMAT():
``` sql
DATE_FORMAT(ss.transaction_date, '%Y-%m')
```
This resolved compatibility issues and allowed monthly grouping.

## Question 3 – Account Inactivity Alert
Scenario
The operations team needed to identify savings and investment accounts with no inflow for over one year or accounts with no recorded transactions. This helps in targeting dormant accounts.

### Objective
Detect accounts with no inflow for over 365 days.

Include accounts with no transaction history.

Classify plans as either 'Savings' or 'Investment'

### Approach
Joined savings_savingsaccount with plans_plan using plan_id.

Used a CASE statement to categorize plans.

Calculated the last transaction date with MAX(transaction_date).

Used DATEDIFF() to compute inactivity duration.

Filtered for accounts where inactivity exceeded 365 days or transactions were null.

### Challenges
Some records had null values in both is_regular_savings and is_a_fund, making plan classification unclear.

### Resolution 
An 'Unknown' category was added for ambiguous plans, ensuring no record was excluded. This also flagged data quality issues, prompting a need for stakeholder clarification.

## Question 4 – Customer Lifetime Value (CLV) Estimation
Scenario
The goal was to estimate the Customer Lifetime Value (CLV) to better understand the profitability of each customer over time.

### Objective
Calculate account tenure in months.

Estimate total transactions per customer.

Apply a fixed profit rate of 0.1% to derive average profit per transaction.

Use the CLV formula to estimate lifetime value and rank customers accordingly.

### Approach
Joined savings_savingsaccount with users_customuser.

Used TIMESTAMPDIFF(MONTH, created_at, CURDATE()) to get tenure.

Applied the formula:

```sql
CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction
```

### Challenges
The initial use of DATEDIFF() returned values in days, not months, misaligning with the task instruction

### Resolution 
I replaced DATEDIFF with TIMESTAMPDIFF to get tenure in months, ensuring consistent units in CLV computation.


