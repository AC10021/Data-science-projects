/* ============================================
CREDIT RISK DATASET - EDA, CLEANING & FEATURE ENGINEERING 
Author: Ambrose Chan Pak Yeung
Source: Kaggle "Credit Risk Dataset" (laotse/credit-risk-dataset)
Run:    sqlite3 credit_risk.db < eda.sql
Output: clean.csv (consumed by modelling.ipynb)
============================================ */ 

/* ============================================
1. EXPLORE
============================================ */ 

/* ----------------------------------------------------------------------------
   1.1 Row count
   ---------------------------------------------------------------------------- */
SELECT COUNT(*) FROM raw_data;

/* ----------------------------------------------------------------------------
   1.2 Column names and data types
   ---------------------------------------------------------------------------- */
PRAGMA table_info(raw_data);

/* ----------------------------------------------------------------------------
   1.3 Peek at the first 10 rows
   ---------------------------------------------------------------------------- */
SELECT *
FROM raw_data
LIMIT 10;

/* ----------------------------------------------------------------------------
   1.4 Missing value counts per column
   ---------------------------------------------------------------------------- */
SELECT
    SUM(CASE WHEN person_age                  IS NULL THEN 1 ELSE 0 END) AS missing_person_age,
    SUM(CASE WHEN person_income               IS NULL THEN 1 ELSE 0 END) AS missing_person_income,
    SUM(CASE WHEN person_home_ownership       IS NULL THEN 1 ELSE 0 END) AS missing_home_ownership,
    SUM(CASE WHEN person_emp_length           IS NULL THEN 1 ELSE 0 END) AS missing_emp_length,
    SUM(CASE WHEN loan_intent                 IS NULL THEN 1 ELSE 0 END) AS missing_loan_intent,
    SUM(CASE WHEN loan_grade                  IS NULL THEN 1 ELSE 0 END) AS missing_loan_grade,
    SUM(CASE WHEN loan_amnt                   IS NULL THEN 1 ELSE 0 END) AS missing_loan_amnt,
    SUM(CASE WHEN loan_int_rate               IS NULL THEN 1 ELSE 0 END) AS missing_int_rate,
    SUM(CASE WHEN loan_status                 IS NULL THEN 1 ELSE 0 END) AS missing_loan_status,
    SUM(CASE WHEN loan_percent_income         IS NULL THEN 1 ELSE 0 END) AS missing_percent_income,
    SUM(CASE WHEN cb_person_default_on_file   IS NULL THEN 1 ELSE 0 END) AS missing_default_on_file,
    SUM(CASE WHEN cb_person_cred_hist_length  IS NULL THEN 1 ELSE 0 END) AS missing_cred_hist_length
FROM raw_data;

/* ----------------------------------------------------------------------------
   1.5 Class imbalance in loan_status (target variable)
   ---------------------------------------------------------------------------- */
SELECT
    loan_status,
    COUNT(*) AS n_loans,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM raw_data), 2) AS pct_of_total
FROM raw_data
GROUP BY loan_status
ORDER BY loan_status;

/* ----------------------------------------------------------------------------
   1.6 Spotting outliers based on personal information
   ---------------------------------------------------------------------------- */
SELECT
    MIN(person_age)  AS min_age,  MAX(person_age)  AS max_age,  AVG(person_age)  AS avg_age,
    MIN(person_emp_length) AS min_emp_length, MAX(person_emp_length) AS max_emp_length,
    MIN(person_income) AS min_income, MAX(person_income) AS max_income
FROM raw_data;

/* ----------------------------------------------------------------------------
   1.7 Duplicate row count
   ---------------------------------------------------------------------------- */
SELECT
    (SELECT COUNT(*) FROM raw_data) AS total_rows,
    (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM raw_data)) AS unique_rows,
    (SELECT COUNT(*) FROM raw_data)
        - (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM raw_data)) AS duplicate_rows;
		
/* ----------------------------------------------------------------------------
   EXPLORATION FINDINGS (summary)
   - 32,581 rows, 12 columns, types all correctly inferred.
   - Missing values: loan_int_rate (3,116 ), person_emp_length (895).
     All other columns complete.
   - Target imbalance: loan_status = 0 (no default) 78.18%, = 1 (default) 21.82%.
   - Outliers: person_age max = 144, person_emp_length max = 123 - both data
     entry errors, not real values.
   - 165 exact duplicate rows.
   These findings drive the cleaning decisions in Section 2 below.
   ---------------------------------------------------------------------------- */
   
 /* ============================================
2. CLEAN
============================================ */ 

/* ----------------------------------------------------------------------------
   2.1 Make a working copy
   ---------------------------------------------------------------------------- */
CREATE TABLE clean_data AS
SELECT * FROM raw_data;

/* ----------------------------------------------------------------------------
   2.2 Remove impossible outliers
   ---------------------------------------------------------------------------- */
DELETE FROM clean_data
WHERE (person_age > 100 AND person_age IS NOT NULL)
   OR (person_emp_length > 60 AND person_emp_length IS NOT NULL);
   
  /* Checking number of remaining rows */
 SELECT COUNT(*) AS rows_remaining FROM clean_data;
 
 /* ----------------------------------------------------------------------------
   2.3 Median-impute missing values (loan_int_rate, person_emp_length)
   ---------------------------------------------------------------------------- */
   
 /* ----------------------------------------------------------------------------
   2.3.1 Calculating median
   ---------------------------------------------------------------------------- */
CREATE TABLE medians AS
SELECT
    (SELECT AVG(val) FROM (
        SELECT loan_int_rate AS val
        FROM clean_data
        WHERE loan_int_rate IS NOT NULL
        ORDER BY val
        LIMIT 2 - (SELECT COUNT(*) FROM clean_data WHERE loan_int_rate IS NOT NULL) % 2
        OFFSET (SELECT (COUNT(*) - 1) / 2 FROM clean_data WHERE loan_int_rate IS NOT NULL)
    )) AS median_int_rate,
    (SELECT AVG(val) FROM (
        SELECT person_emp_length AS val
        FROM clean_data
        WHERE person_emp_length IS NOT NULL
        ORDER BY val
        LIMIT 2 - (SELECT COUNT(*) FROM clean_data WHERE person_emp_length IS NOT NULL) % 2
        OFFSET (SELECT (COUNT(*) - 1) / 2 FROM clean_data WHERE person_emp_length IS NOT NULL)
    )) AS median_emp_length;
	
/* Checking median value */
	SELECT * FROM medians;
	
/* ----------------------------------------------------------------------------
   2.3.2 Flagging rows with missing values
   ---------------------------------------------------------------------------- */
ALTER TABLE clean_data ADD COLUMN int_rate_was_missing INTEGER;
ALTER TABLE clean_data ADD COLUMN emp_length_was_missing INTEGER;

UPDATE clean_data
SET int_rate_was_missing = CASE WHEN loan_int_rate IS NULL THEN 1 ELSE 0 END;
UPDATE clean_data
SET emp_length_was_missing = CASE WHEN person_emp_length IS NULL THEN 1 ELSE 0 END;

/* Number of rows with 0/1/2 missing information */
SELECT int_rate_was_missing, emp_length_was_missing, COUNT(*)
FROM clean_data
GROUP BY int_rate_was_missing, emp_length_was_missing;

/* ----------------------------------------------------------------------------
   2.3.3 Filling missing values with medians
   ---------------------------------------------------------------------------- */
UPDATE clean_data
SET loan_int_rate = (SELECT median_int_rate FROM medians)
WHERE loan_int_rate IS NULL;

UPDATE clean_data
SET person_emp_length = (SELECT median_emp_length FROM medians)
WHERE person_emp_length IS NULL;

/* ----------------------------------------------------------------------------
   2.3.4 Verifying no missing values remain
   ---------------------------------------------------------------------------- */
SELECT
    SUM(CASE WHEN loan_int_rate     IS NULL THEN 1 ELSE 0 END) AS still_missing_int_rate,
    SUM(CASE WHEN person_emp_length IS NULL THEN 1 ELSE 0 END) AS still_missing_emp_length
FROM clean_data;

/* ----------------------------------------------------------------------------
   2.4 Remove duplicate rows
   ---------------------------------------------------------------------------- */
DELETE FROM clean_data
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM clean_data
    GROUP BY person_age, person_income, person_home_ownership, person_emp_length,
             loan_intent, loan_grade, loan_amnt, loan_int_rate, loan_status,
             loan_percent_income, cb_person_default_on_file, cb_person_cred_hist_length,
             int_rate_was_missing, emp_length_was_missing
);
  
/* Confirming 165 duplicated rows deleted */
SELECT COUNT(*) AS rows_remaining FROM clean_data;

/* ----------------------------------------------------------------------------
   2.5 Confirm INTEGER type
   ---------------------------------------------------------------------------- */
UPDATE clean_data
SET loan_status = CAST(loan_status AS INTEGER);

/* ----------------------------------------------------------------------------
   2.6 Verify cleaning worked
   ---------------------------------------------------------------------------- */
SELECT
    COUNT(*) AS n_rows_after_cleaning,
    SUM(CASE WHEN loan_int_rate     IS NULL THEN 1 ELSE 0 END) AS still_missing_int_rate,
    SUM(CASE WHEN person_emp_length IS NULL THEN 1 ELSE 0 END) AS still_missing_emp_length,
    MAX(person_age) AS max_age_after_cleaning,
    MAX(person_emp_length) AS max_emp_length_after_cleaning
FROM clean_data;

 /* ============================================
3. FEATURE ENGINEERING 
============================================ */ 

CREATE TABLE features AS
SELECT
    c.*,

    /* Prior default history (strongest classic predictor of repeat default) */
    CASE WHEN c.cb_person_default_on_file = 'Y' THEN 1 ELSE 0 END
        AS prior_default_flag,

	/* Income-to-loan ratio */
	ROUND (c.person_income *1.0 / NULLIF (c.loan_amnt, 0), 2)
		AS income_to_loan_ratio,
		
	/* Credit maturity relative to adult lifetime */
	ROUND(c.cb_person_cred_hist_length * 1.0 / NULLIF((c.person_age - 18), 0), 2)
		AS credit_history_to_age_ratio,

	/* High risk grade flag */
	CASE WHEN c.loan_grade IN ('D', 'E', 'F', 'G') THEN 1 ELSE 0 END
		AS high_risk_grade_flag,
		
	/* Employment stability */
	CASE
		WHEN c.person_emp_length < 2  THEN 'early_career'
		WHEN c.person_emp_length < 5  THEN 'developing'
		WHEN c.person_emp_length < 10 THEN 'established'
		ELSE 'veteran'
	END AS employment_stability_bucket,
	
	/* Age group */
	CASE
		WHEN c.person_age < 25 THEN '20-24'
		WHEN c.person_age < 30 THEN '25-29'
		WHEN c.person_age < 40 THEN '30-39'
		WHEN c.person_age < 50 THEN '40-49'
		ELSE '50+'
	END AS age_group,
	
	/* Rent flag */
	CASE WHEN c.person_home_ownership = 'RENT' THEN 1 ELSE 0 END
		AS rent_flag
		
FROM clean_data c;

/* Viewing the first 10 rows */
SELECT 
	credit_history_to_age_ratio, prior_default_flag, rent_flag, age_group, employment_stability_bucket,
	high_risk_grade_flag, income_to_loan_ratio
FROM features 
LIMIT 10;

 /* ============================================
4. EXPORT
============================================ */ 

/* ----------------------------------------------------------------------------
   4.1 Export the features table to clean.csv
   ----------------------------------------------------------------------------
   Performed via DB Browser's GUI: File -> Export -> Table as CSV,
   selecting the `features` table, with "Column names in first line" checked.
   This is the handoff point from SQL to Python - modelling.ipynb loads
   clean.csv directly with pd.read_csv('clean.csv').
   ---------------------------------------------------------------------------- */

/* ----------------------------------------------------------------------------
   4.2 Final confirmation
   ---------------------------------------------------------------------------- */
SELECT
    COUNT(*) AS n_rows,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS n_defaults,
    SUM(CASE WHEN loan_status = 0 THEN 1 ELSE 0 END) AS n_non_defaults
FROM features;
   
