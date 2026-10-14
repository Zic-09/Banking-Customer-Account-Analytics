USE real_projects;

-- =========================================================
-- CREATED A COPY OF THE ORIGINAL TABLES
-- =========================================================

CREATE TABLE customer_copy AS
    SELECT * FROM customer;

CREATE TABLE bank_account_details_copy AS 
    SELECT * FROM bank_account_details;
-- =========================================================
-- PART 1: PROFILE THE MESS
-- =========================================================
SELECT * FROM customer_copy LIMIT 10;
SELECT * FROM bank_account_details_copy LIMIT 10;
SELECT COUNT(*) AS rows_in_customer FROM customer_copy;
SELECT COUNT(*) AS rows_in_accounts FROM bank_account_details_copy;

-- Find possible duplicate customer contact details
SELECT phone, COUNT(*) AS occurrences
FROM customer_copy
WHERE phone IS NOT NULL AND TRIM(phone) != ''
GROUP BY phone
HAVING COUNT(*) > 1;

SELECT LOWER(TRIM(email)) AS normalized_email, COUNT(*) AS occurrences
FROM customer_copy
WHERE email IS NOT NULL AND TRIM(email) != ''
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1;

SELECT TRIM(bvn) AS bvn, COUNT(*) AS occurrences
FROM customer_copy
WHERE bvn IS NOT NULL AND TRIM(bvn) != ''
GROUP BY TRIM(bvn)
HAVING COUNT(*) > 1;

SELECT TRIM(account_number) AS account_number, COUNT(*) AS occurrences
FROM bank_account_details_copy
WHERE account_number IS NOT NULL AND TRIM(account_number) != ''
GROUP BY TRIM(account_number)
HAVING COUNT(*) > 1;

-- For duplicate across the entire records --
SELECT
    customer_id, first_name, last_name, gender, date_of_birth, phone, email,
    city, state, customer_tier, registration_date, bvn, COUNT(*) AS occurrences
FROM customer_copy
GROUP BY customer_id, first_name, last_name, gender, date_of_birth, phone,
    email, city, state, customer_tier, registration_date, bvn
HAVING COUNT(*) > 1;

SELECT
    account_id, customer_id, account_number, account_type, account_status, date_opened,
    current_balance, interest_rate, overdraft_limit, branch, last_transaction_date, COUNT(*) AS occurrences
FROM bank_account_details_copy
GROUP BY
    account_id, customer_id, account_number, account_type, account_status, date_opened,
    current_balance, interest_rate, overdraft_limit, branch, last_transaction_date
HAVING COUNT(*) > 1;

-- Look for missing values
SELECT
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_id,
    SUM(first_name IS NULL OR TRIM(first_name) = '') AS missing_first_name,
    SUM(last_name IS NULL OR TRIM(last_name) = '') AS missing_last_name,
    SUM(gender IS NULL OR TRIM(gender) = '') AS missing_gender,
    SUM(date_of_birth IS NULL OR TRIM(date_of_birth) = '') AS missing_DOB,
    SUM(phone IS NULL OR TRIM(phone) = '') AS missing_phone,
    SUM(email IS NULL OR TRIM(email) = '') AS missing_email,
    SUM(city IS NULL OR TRIM(city) = '') AS missing_city,
    SUM(state IS NULL OR TRIM(state) = '') AS missing_state,
    SUM(customer_tier IS NULL OR TRIM(customer_tier) = '') AS missing_CT,
    SUM(registration_date IS NULL OR TRIM(registration_date) = '') AS missing_RD,
    SUM(bvn IS NULL OR TRIM(bvn) = '') AS missing_bvn
FROM customer_copy;

SELECT
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_id,
    SUM(account_number IS NULL OR TRIM(account_number) = '') AS missing_account_number,
    SUM(account_type IS NULL OR TRIM(account_type) = '') AS missing_accouunt_type,
    SUM(account_status IS NULL OR TRIM(account_status) = '') AS missing_account_status,
    SUM(date_opened IS NULL OR TRIM(date_opened) = '') AS missing_date_opened,
    SUM(current_balance IS NULL OR TRIM(current_balance) = '') AS missing_balance,
    SUM(interest_rate IS NULL OR TRIM(interest_rate) = '') AS missing_interest_rate,
    SUM(overdraft_limit IS NULL OR TRIM(overdraft_limit) = '') AS missing_ODL,
    SUM(branch IS NULL OR TRIM(branch) = '') AS missing_branch,
    SUM(last_transaction_date IS NULL OR TRIM(last_transaction_date) = '') AS missing_LTD
FROM bank_account_details_copy;

-- =========================================================
-- PART 2: CLEAN CUSTOMER TABLE
-- =========================================================

-- Standardize whitespace and case
UPDATE customer_copy
SET
    customer_id = UPPER(TRIM(customer_id)),
    first_name = CONCAT(UPPER(LEFT(TRIM(first_name),1)), LOWER(SUBSTRING(TRIM(first_name),2))),
    last_name = CONCAT(UPPER(LEFT(TRIM(last_name),1)), LOWER(SUBSTRING(TRIM(last_name),2))),
    gender = CASE
        WHEN UPPER(TRIM(gender)) IN ('M','MALE') THEN 'Male'
        WHEN UPPER(TRIM(gender)) IN ('F','FEMALE') THEN 'Female'
        ELSE NULL
    END,
    phone = NULLIF(REPLACE(REPLACE(TRIM(phone), ' ', ''), '+234', '0'), ''),
    email = LOWER(NULLIF(TRIM(email), '')),
    city = CONCAT(UPPER(LEFT(TRIM(city),1)), LOWER(SUBSTRING(TRIM(city),2))),
    state = CONCAT(UPPER(LEFT(TRIM(state),1)), LOWER(SUBSTRING(TRIM(state),2))),
    customer_tier = CONCAT(UPPER(LEFT(TRIM(customer_tier),1)), LOWER(SUBSTRING(TRIM(customer_tier),2))),
    bvn = NULLIF(TRIM(bvn), '');

SELECT * FROM customer_copy;

-- Updated Yusuf's email to the correct mail --
SELECT * FROM customer_copy WHERE email = "chinedu.balogun2@example.com";
UPDATE customer_copy
SET
    email = "yusufmohammed1@example.com"
WHERE customer_id = "CUST1097";

-- Convert date fields from VARCHAR to DATE --

-- # First, I added new columns to hold the cleaned date values --
ALTER TABLE customer_copy ADD COLUMN Date_of_Birth_clean DATE;
ALTER TABLE customer_copy ADD COLUMN Registration_Date_clean DATE;

UPDATE customer_copy
SET
    Date_of_Birth_clean = STR_TO_DATE(NULLIF(TRIM(date_of_birth), ''), '%Y-%m-%d'),
    Registration_Date_clean = STR_TO_DATE(NULLIF(TRIM(registration_date), ''), '%Y-%m-%d');

ALTER TABLE customer_copy
    DROP COLUMN date_of_birth,
    DROP COLUMN registration_date,
    CHANGE Date_of_Birth_clean date_of_birth DATE,
    CHANGE Registration_Date_clean registration_date DATE;

-- =========================================================
-- PART 3: CLEAN ACCOUNT TABLE
-- =========================================================

SELECT * FROM bank_account_details_copy;
UPDATE bank_account_details_copy
SET
    account_id = UPPER(TRIM(account_id)),
    customer_id = UPPER(TRIM(customer_id)),
    account_number = REPLACE(TRIM(account_number), ' ', ''),
    account_type = CONCAT(UPPER(LEFT(TRIM(account_type),1)), LOWER(SUBSTRING(TRIM(account_type),2))),
    account_status = CONCAT(UPPER(LEFT(TRIM(account_status),1)), LOWER(SUBSTRING(TRIM(account_status),2))),
    branch = CONCAT(UPPER(LEFT(TRIM(branch),1)), LOWER(SUBSTRING(TRIM(branch),2)));

-- I removed the % sign and spaces from interest rate before conversion
UPDATE bank_account_details_copy
SET interest_rate = REPLACE(TRIM(interest_rate), '%', ''),
    current_balance = REPLACE(TRIM(current_balance), ',', ''),
    overdraft_limit = REPLACE(TRIM(overdraft_limit), ',', '');

-- I added properly typed columns
ALTER TABLE bank_account_details_copy
    ADD COLUMN date_opened_clean DATE,
    ADD COLUMN current_balance_clean DECIMAL(15,2),
    ADD COLUMN interest_rate_clean DECIMAL(5,2),
    ADD COLUMN overdraft_limit_clean DECIMAL(15,2),
    ADD COLUMN last_transaction_date_clean DATE;

UPDATE bank_account_details_copy
SET
    date_opened_clean = STR_TO_DATE(NULLIF(TRIM(date_opened), ''), '%Y-%m-%d'),
    current_balance_clean = CAST(NULLIF(TRIM(current_balance), '') AS DECIMAL(15,2)),
    interest_rate_clean = CAST(NULLIF(TRIM(interest_rate), '') AS DECIMAL(5,2)),
    overdraft_limit_clean = CAST(NULLIF(TRIM(overdraft_limit), '') AS DECIMAL(15,2)),
    last_transaction_date_clean = STR_TO_DATE(NULLIF(TRIM(last_transaction_date), ''), '%Y-%m-%d');

ALTER TABLE bank_account_details_copy
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

SELECT * FROM bank_account_details_copy;

-- =========================================================
-- PART 4: DATA VALIDATION
-- =========================================================

-- Checking for orphan account records before adding the FK
SELECT a.customer_id
FROM bank_account_details_copy a
LEFT JOIN customer_copy c ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Checking for duplicated primary-key candidates
SELECT customer_id, COUNT(*) AS cnt
FROM customer_copy
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT account_id, COUNT(*) AS cnt
FROM bank_account_details_copy
GROUP BY account_id
HAVING COUNT(*) > 1;

SELECT account_number, COUNT(*) AS cnt
FROM bank_account_details_copy
GROUP BY account_number
HAVING COUNT(*) > 1;

-- I added keys after cleaning/validation.
ALTER TABLE customer_copy
    ADD CONSTRAINT pk_customer PRIMARY KEY (customer_id);

ALTER TABLE bank_account_details_copy
    ADD CONSTRAINT pk_bank_account PRIMARY KEY (account_id);

ALTER TABLE bank_account_details_copy
    ADD CONSTRAINT fk_account_customer
    FOREIGN KEY (customer_id)
    REFERENCES customer_copy(customer_id);

-- I made the account number unique --.
ALTER TABLE bank_account_details_copy
    ADD CONSTRAINT uq_account_number UNIQUE (account_number);

-- =========================================================
-- PART 5: BUSINESS QUESTIONS + ANSWERS
-- =========================================================

-- Q1. How many customers are in the bank?
SELECT COUNT(*) AS total_customers
FROM customer_copy;

-- Q2. How many accounts exist by account type?
SELECT account_type, COUNT(*) AS total_accounts
FROM bank_account_details_copy
GROUP BY account_type
ORDER BY total_accounts DESC;

-- Q3. What is the total current balance by account type?
SELECT
    account_type,
    ROUND(SUM(current_balance),2) AS total_balance
FROM bank_account_details_copy
GROUP BY account_type
ORDER BY total_balance DESC;

-- Q4. Which customers hold more than one bank account?
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(a.account_id) AS number_of_accounts
FROM customer_copy c
JOIN bank_account_details_copy a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(a.account_id) > 1
ORDER BY number_of_accounts DESC;

-- Q5. Which branch holds the highest total account balance?
SELECT
    branch,
    ROUND(SUM(current_balance),2) AS total_balance
FROM bank_account_details_copy
GROUP BY branch
ORDER BY total_balance DESC
LIMIT 1;

-- Q6. What percentage of accounts are currently active?
SELECT
    ROUND(
        100.0 * SUM(account_status = 'Active') / COUNT(*),
        2
    ) AS active_account_percentage
FROM bank_account_details_copy;

-- Q7. Which customers have the highest total balances?
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(a.current_balance),2) AS total_balance
FROM customer_copy c
JOIN bank_account_details_copy a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_balance DESC
LIMIT 10;

-- Q8. How much money is held by each customer tier?
SELECT
    c.customer_tier,
    ROUND(SUM(a.current_balance),2) AS total_balance,
    COUNT(DISTINCT c.customer_id) AS customers
FROM customer_copy c
JOIN bank_account_details_copy a
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
FROM bank_account_details_copy a
JOIN customer_copy c
    ON a.customer_id = c.customer_id
WHERE a.current_balance < 0
ORDER BY a.current_balance ASC;

-- Q10. Which account type has the highest average interest rate?
SELECT
    account_type,
    ROUND(AVG(interest_rate),2) AS average_interest_rate
FROM bank_account_details_copy
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
FROM customer_copy c
INNER JOIN bank_account_details_copy a
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
