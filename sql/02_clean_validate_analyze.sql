USE banking_data_cleaning;

-- =========================================================
-- PART 1: PROFILE THE MESS
-- =========================================================

SELECT COUNT(*) AS rows_in_customer FROM customer;
SELECT COUNT(*) AS rows_in_accounts FROM bank_account_details;

-- Find possible duplicate customer contact details
SELECT phone, COUNT(*) AS occurrences
FROM customer
WHERE phone IS NOT NULL AND TRIM(phone) != ''
GROUP BY phone
HAVING COUNT(*) > 1;

SELECT LOWER(TRIM(email)) AS normalized_email, COUNT(*) AS occurrences
FROM customer
WHERE email IS NOT NULL AND TRIM(email) != ''
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1;

-- Look for missing values
SELECT
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_id,
    SUM(first_name IS NULL OR TRIM(first_name) = '') AS missing_first_name,
    SUM(last_name IS NULL OR TRIM(last_name) = '') AS missing_last_name,
    SUM(phone IS NULL OR TRIM(phone) = '') AS missing_phone,
    SUM(email IS NULL OR TRIM(email) = '') AS missing_email,
    SUM(bvn IS NULL OR TRIM(bvn) = '') AS missing_bvn
FROM customer;

SELECT
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_id,
    SUM(account_number IS NULL OR TRIM(account_number) = '') AS missing_account_number,
    SUM(current_balance IS NULL OR TRIM(current_balance) = '') AS missing_balance,
    SUM(interest_rate IS NULL OR TRIM(interest_rate) = '') AS missing_interest_rate
FROM bank_account_details;

-- =========================================================
-- PART 2: CLEAN CUSTOMER TABLE
-- =========================================================

-- Standardize whitespace and case
UPDATE customer
SET
    customer_id = UPPER(TRIM(customer_id)),
    first_name = CONCAT(UPPER(LEFT(TRIM(first_name),1)), LOWER(SUBSTRING(TRIM(first_name),2))),
    last_name = CONCAT(UPPER(LEFT(TRIM(last_name),1)), LOWER(SUBSTRING(TRIM(last_name),2))),
    gender = CASE
        WHEN UPPER(TRIM(gender)) IN ('M','MALE') THEN 'Male'
        WHEN UPPER(TRIM(gender)) IN ('F','FEMALE') THEN 'Female'
        ELSE NULL
    END,
    phone = NULLIF(REPLACE(REPLACE(TRIM(phone), ' ', ''), '-', ''), ''),
    email = LOWER(NULLIF(TRIM(email), '')),
    city = CONCAT(UPPER(LEFT(TRIM(city),1)), LOWER(SUBSTRING(TRIM(city),2))),
    state = CONCAT(UPPER(LEFT(TRIM(state),1)), LOWER(SUBSTRING(TRIM(state),2))),
    customer_tier = CONCAT(UPPER(LEFT(TRIM(customer_tier),1)), LOWER(SUBSTRING(TRIM(customer_tier),2))),
    bvn = NULLIF(TRIM(bvn), '');

-- Convert date fields from VARCHAR to DATE
ALTER TABLE customer ADD COLUMN dob_clean DATE;
ALTER TABLE customer ADD COLUMN registration_date_clean DATE;

UPDATE customer
SET
    dob_clean = STR_TO_DATE(NULLIF(TRIM(date_of_birth), ''), '%Y-%m-%d'),
    registration_date_clean = STR_TO_DATE(NULLIF(TRIM(registration_date), ''), '%Y-%m-%d');

ALTER TABLE customer
    DROP COLUMN date_of_birth,
    DROP COLUMN registration_date,
    CHANGE dob_clean date_of_birth DATE,
    CHANGE registration_date_clean registration_date DATE;

-- =========================================================
-- PART 3: CLEAN ACCOUNT TABLE
-- =========================================================

UPDATE bank_account_details
SET
    account_id = UPPER(TRIM(account_id)),
    customer_id = UPPER(TRIM(customer_id)),
    account_number = REPLACE(TRIM(account_number), ' ', ''),
    account_type = CONCAT(UPPER(LEFT(TRIM(account_type),1)), LOWER(SUBSTRING(TRIM(account_type),2))),
    account_status = CONCAT(UPPER(LEFT(TRIM(account_status),1)), LOWER(SUBSTRING(TRIM(account_status),2))),
    branch = CONCAT(UPPER(LEFT(TRIM(branch),1)), LOWER(SUBSTRING(TRIM(branch),2)));

-- Remove the % sign and spaces from interest rate before conversion
UPDATE bank_account_details
SET interest_rate = REPLACE(TRIM(interest_rate), '%', ''),
    current_balance = REPLACE(TRIM(current_balance), ',', ''),
    overdraft_limit = REPLACE(TRIM(overdraft_limit), ',', '');

-- Add properly typed columns
ALTER TABLE bank_account_details
    ADD COLUMN date_opened_clean DATE,
    ADD COLUMN current_balance_clean DECIMAL(15,2),
    ADD COLUMN interest_rate_clean DECIMAL(5,2),
    ADD COLUMN overdraft_limit_clean DECIMAL(15,2),
    ADD COLUMN last_transaction_date_clean DATE;

UPDATE bank_account_details
SET
    date_opened_clean = STR_TO_DATE(NULLIF(TRIM(date_opened), ''), '%Y-%m-%d'),
    current_balance_clean = CAST(NULLIF(TRIM(current_balance), '') AS DECIMAL(15,2)),
    interest_rate_clean = CAST(NULLIF(TRIM(interest_rate), '') AS DECIMAL(5,2)),
    overdraft_limit_clean = CAST(NULLIF(TRIM(overdraft_limit), '') AS DECIMAL(15,2)),
    last_transaction_date_clean = STR_TO_DATE(NULLIF(TRIM(last_transaction_date), ''), '%Y-%m-%d');

ALTER TABLE bank_account_details
    DROP COLUMN date_opened,
    DROP COLUMN current_balance,
    DROP COLUMN interest_rate,
    DROP COLUMN overdraft_limit,
    DROP COLUMN last_transaction_date,
    CHANGE date_opened_clean date_opened DATE,
    CHANGE current_balance_clean current_balance DECIMAL(15,2),
    CHANGE interest_rate_clean interest_rate DECIMAL(5,2),
    CHANGE overdraft_limit_clean overdraft_limit DECIMAL(15,2),
    CHANGE last_transaction_date_clean last_transaction_date DATE;

-- =========================================================
-- PART 4: DATA VALIDATION
-- =========================================================

-- Check for orphan account records before adding the FK
SELECT a.customer_id
FROM bank_account_details a
LEFT JOIN customer c ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check duplicate primary-key candidates
SELECT customer_id, COUNT(*) AS cnt
FROM customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT account_id, COUNT(*) AS cnt
FROM bank_account_details
GROUP BY account_id
HAVING COUNT(*) > 1;

SELECT account_number, COUNT(*) AS cnt
FROM bank_account_details
GROUP BY account_number
HAVING COUNT(*) > 1;

-- Add keys after cleaning/validation.
ALTER TABLE customer
    ADD CONSTRAINT pk_customer PRIMARY KEY (customer_id);

ALTER TABLE bank_account_details
    ADD CONSTRAINT pk_bank_account PRIMARY KEY (account_id);

ALTER TABLE bank_account_details
    ADD CONSTRAINT fk_account_customer
    FOREIGN KEY (customer_id)
    REFERENCES customer(customer_id);

-- Recommended business rule: account number should also be unique.
ALTER TABLE bank_account_details
    ADD CONSTRAINT uq_account_number UNIQUE (account_number);

-- =========================================================
-- PART 5: 10 BUSINESS QUESTIONS + ANSWERS
-- =========================================================

-- Q1. How many customers are in the bank?
SELECT COUNT(*) AS total_customers
FROM customer;

-- Q2. How many accounts exist by account type?
SELECT account_type, COUNT(*) AS total_accounts
FROM bank_account_details
GROUP BY account_type
ORDER BY total_accounts DESC;

-- Q3. What is the total current balance by account type?
SELECT
    account_type,
    ROUND(SUM(current_balance),2) AS total_balance
FROM bank_account_details
GROUP BY account_type
ORDER BY total_balance DESC;

-- Q4. Which customers hold more than one bank account?
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(a.account_id) AS number_of_accounts
FROM customer c
JOIN bank_account_details a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(a.account_id) > 1
ORDER BY number_of_accounts DESC;

-- Q5. Which branch holds the highest total account balance?
SELECT
    branch,
    ROUND(SUM(current_balance),2) AS total_balance
FROM bank_account_details
GROUP BY branch
ORDER BY total_balance DESC
LIMIT 1;

-- Q6. What percentage of accounts are currently active?
SELECT
    ROUND(
        100.0 * SUM(account_status = 'Active') / COUNT(*),
        2
    ) AS active_account_percentage
FROM bank_account_details;

-- Q7. Which customers have the highest total balances?
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(a.current_balance),2) AS total_balance
FROM customer c
JOIN bank_account_details a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_balance DESC
LIMIT 10;

-- Q8. How much money is held by each customer tier?
SELECT
    c.customer_tier,
    ROUND(SUM(a.current_balance),2) AS total_balance,
    COUNT(DISTINCT c.customer_id) AS customers
FROM customer c
JOIN bank_account_details a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_tier
ORDER BY total_balance DESC;

-- Q9. Which accounts have a negative balance?
SELECT
    a.account_id,
    a.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    a.account_type,
    a.current_balance,
    a.overdraft_limit
FROM bank_account_details a
JOIN customer c
    ON a.customer_id = c.customer_id
WHERE a.current_balance < 0
ORDER BY a.current_balance ASC;

-- Q10. Which account type has the highest average interest rate?
SELECT
    account_type,
    ROUND(AVG(interest_rate),2) AS average_interest_rate
FROM bank_account_details
GROUP BY account_type
ORDER BY average_interest_rate DESC
LIMIT 1;

-- =========================================================
-- PART 6: POWER BI DATASET
-- =========================================================

-- A flattened analysis view. One row = one bank account.
-- Customer attributes are repeated for customers with multiple accounts.
CREATE OR REPLACE VIEW vw_customer_account_analysis AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.gender,
    c.date_of_birth,
    TIMESTAMPDIFF(YEAR, c.date_of_birth, CURDATE()) AS customer_age,
    c.phone,
    c.email,
    c.city,
    c.state,
    c.customer_tier,
    c.registration_date,
    a.account_id,
    a.account_number,
    a.account_type,
    a.account_status,
    a.date_opened,
    a.current_balance,
    a.interest_rate,
    a.overdraft_limit,
    a.branch,
    a.last_transaction_date,
    DATEDIFF(CURDATE(), a.last_transaction_date) AS days_since_last_transaction
FROM customer c
INNER JOIN bank_account_details a
    ON c.customer_id = a.customer_id;

-- Check the Power BI dataset
SELECT * FROM vw_customer_account_analysis LIMIT 20;

-- Optional physical table if a BI tool specifically
-- requires a table instead of a view:
DROP TABLE IF EXISTS banking_analysis;
CREATE TABLE banking_analysis AS
SELECT * FROM vw_customer_account_analysis;

-- Final row count
SELECT COUNT(*) AS power_bi_rows
FROM banking_analysis;
