# Banking Customer & Account Analytics

## SQL Data Cleaning + Financial Analysis + Power BI

A practical end-to-end banking analytics project demonstrating how a Data Analyst can take messy relational data, clean and validate it with MySQL, answer business questions with SQL, and prepare a trusted dataset for Power BI reporting.

## Business Context

A retail bank wants to understand its customer base and account portfolio. Management needs visibility into customer and account volumes, account activity, balances by branch and account type, customer tiers, customers with multiple accounts, negative balances, and interest-rate patterns.

The source data is deliberately not analysis-ready. It contains inconsistent text, whitespace, missing values, inconsistent casing, improperly formatted financial values, and fields that need to be converted into appropriate data types.

## Business Questions

1. How many customers are in the bank?
2. How many accounts exist by account type?
3. What is the total current balance by account type?
4. Which customers hold more than one bank account?
5. Which branch holds the highest total account balance?
6. What percentage of accounts are currently active?
7. Which customers have the highest total balances?
8. How much money is held by each customer tier?
9. Which accounts have negative balances?
10. Which account type has the highest average interest rate?

## Data Model

```text
CUSTOMER
---------
PK customer_id
   first_name
   last_name
   gender
   date_of_birth
   phone
   email
   city
   state
   customer_tier
   registration_date
   bvn

              1
              |
              | customer_id
              |
              ∞

BANK_ACCOUNT_DETAILS
--------------------
PK account_id
FK customer_id
   account_number
   account_type
   account_status
   date_opened
   current_balance
   interest_rate
   overdraft_limit
   branch
   last_transaction_date
```

One customer can have multiple bank accounts.

## Data Quality Challenges

The raw dataset intentionally contains realistic data-quality issues for analysis and cleaning practice:

- leading and trailing whitespace
- inconsistent upper/lower/title case
- inconsistent gender values such as `M`, `Male`, `F`, and `Female`
- inconsistent phone formatting
- duplicate contact values
- missing phone, email, BVN, and balance values
- financial values stored as text
- commas inside balance values
- interest rates containing `%`
- date fields initially stored as text
- inconsistent account status values
- inconsistent foreign-key formatting

## SQL Workflow

**1. Create and load raw data**

`sql/01_create_and_load_messy_data.sql` creates `banking_data_cleaning` and loads the two raw tables.

**2. Profile the data**

Check row counts, missing values, duplicate candidates, inconsistent values, and possible orphan foreign keys.

**3. Clean the data**

The workflow uses `TRIM()`, `UPPER()`, `LOWER()`, `CASE`, `REPLACE()`, `NULLIF()`, `CAST()`, `STR_TO_DATE()`, and conditional aggregation.

**4. Validate the cleaned data**

Check duplicate primary-key candidates, duplicate account numbers, orphan customer IDs, and cleaned data types before adding constraints.

**5. Add relational constraints**

Primary key on `customer.customer_id`, primary key on `bank_account_details.account_id`, foreign key from `bank_account_details.customer_id`, and a unique constraint on `account_number`.

**6. Analyse the data**

The SQL script contains answers to the 10 business questions.

**7. Prepare the Power BI layer**

A SQL view called `vw_customer_account_analysis` combines customer and account information into a reporting-ready dataset.

## Power BI Layer

Power BI can connect directly to MySQL and use `vw_customer_account_analysis` as the reporting dataset.

Recommended dashboard sections:

### Executive KPIs
- Total Customers
- Total Accounts
- Total Balance
- Average Balance
- Active Account %
- Negative Balance Accounts

### Customer Analysis
- Customers by Tier
- Customers by State
- Top Customers by Total Balance
- Customers with Multiple Accounts

### Account Analysis
- Accounts by Type
- Accounts by Status
- Balance by Account Type
- Average Interest Rate by Account Type

### Branch Analysis
- Total Balance by Branch
- Account Volume by Branch
- Average Balance by Branch

### Risk / Monitoring
- Negative Balance Accounts
- Dormant Accounts
- Days Since Last Transaction

## Repository Structure

```text
banking-sql-powerbi-analytics/
│
├── README.md
├── .gitignore
│
├── sql/
│   ├── 01_create_and_load_messy_data.sql
│   └── 02_clean_validate_analyze.sql
│
├── docs/
│   ├── data_dictionary.md
│   └── case_study.md
│
├── powerbi/
│   └── powerbi_build_guide.md
│
└── screenshots/
    └── add_dashboard_screenshots_here
```

## Tools

MySQL | MySQL Workbench | SQL | Power BI | Git | GitHub

## What This Project Demonstrates

### Technical
- relational database design
- primary and foreign keys
- data profiling
- data cleaning
- data type conversion
- duplicate detection
- missing-value handling
- SQL joins
- aggregation and conditional aggregation
- financial analysis
- validation checks
- SQL views
- Power BI data preparation

### Analytical

The project demonstrates the workflow:

**Business problem → raw data → data quality assessment → cleaning → validation → analysis → BI-ready dataset → visualization**

## Portfolio Note

This is a simulated banking dataset created for portfolio and learning purposes. It does not contain real customer banking information.

## Author

**Toluwanimi**  
Data Analyst | SQL | Power BI | Excel | Python
