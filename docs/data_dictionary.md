# Data Dictionary

## Customer

| Column | Description | Final Type | Key |
|---|---|---|---|
| customer_id | Unique customer identifier | VARCHAR(30) | PK |
| first_name | Customer first name | VARCHAR(100) | |
| last_name | Customer surname | VARCHAR(100) | |
| gender | Standardized gender category | VARCHAR(30) | |
| date_of_birth | Customer date of birth | DATE | |
| phone | Customer phone number | VARCHAR(50) | |
| email | Customer email address | VARCHAR(150) | |
| city | Customer city | VARCHAR(100) | |
| state | Customer state | VARCHAR(100) | |
| customer_tier | Customer relationship tier | VARCHAR(50) | |
| registration_date | Customer registration date | DATE | |
| bvn | Simulated banking verification identifier | VARCHAR(30) | |

## Bank Account Details

| Column | Description | Final Type | Key |
|---|---|---|---|
| account_id | Unique account record identifier | VARCHAR(30) | PK |
| customer_id | Customer who owns the account | VARCHAR(30) | FK |
| account_number | Bank account number | VARCHAR(40) | Unique |
| account_type | Savings, Current, Salary or Student | VARCHAR(50) | |
| account_status | Active, Inactive, Dormant or Closed | VARCHAR(50) | |
| date_opened | Date account was opened | DATE | |
| current_balance | Current account balance | DECIMAL(15,2) | |
| interest_rate | Account interest rate | DECIMAL(5,2) | |
| overdraft_limit | Approved overdraft limit | DECIMAL(15,2) | |
| branch | Servicing branch | VARCHAR(100) | |
| last_transaction_date | Date of most recent transaction | DATE | |

All data is simulated for portfolio and educational purposes.
