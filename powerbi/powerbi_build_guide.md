# Power BI Build Guide

## Connection

1. Open Power BI Desktop.
2. Select **Get Data**.
3. Select **MySQL database**.
4. Enter your MySQL Server and database name.
5. Database: `banking_data_cleaning`
6. Select `vw_customer_account_analysis`.
7. Load the dataset.

## Suggested Dashboard

### Page 1: Executive Overview

Cards:
- Total Customers
- Total Accounts
- Total Balance
- Average Account Balance
- Active Account %
- Negative Balance Accounts

Charts:
- Total Balance by Branch
- Total Balance by Account Type
- Accounts by Status

Slicers:
- State
- Branch
- Account Type
- Account Status
- Customer Tier

### Page 2: Customer Analysis

- Top 10 Customers by Balance
- Customers by Tier
- Customers by State
- Number of Accounts per Customer

### Page 3: Account & Risk Analysis

- Negative Balance Accounts
- Average Interest Rate by Account Type
- Account Status by Branch
- Days Since Last Transaction

## Portfolio Tip

After completing the dashboard, take clean screenshots and place them in `screenshots/`. Reference the screenshots in the README.

Never upload real banking credentials, passwords, connection strings, or real customer data.
