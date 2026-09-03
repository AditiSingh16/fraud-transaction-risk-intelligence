-- ============================================================
-- FRAUD & TRANSACTION RISK INTELLIGENCE
-- DATA QUALITY CHECKS
-- ============================================================
 -- ============================================================
-- 1. TOTAL TRANSACTIONS
-- ============================================================

SELECT COUNT(*) AS total_transactions
FROM public.train_transactions;

-- ============================================================
-- 2. FRAUD DISTRIBUTION
-- ============================================================

SELECT COUNT(*) AS total_transactions,
       SUM(CASE
               WHEN "isFraud" = 1 THEN 1
               ELSE 0
           END) AS fraudulent_transactions,
       SUM(CASE
               WHEN "isFraud" = 0 THEN 1
               ELSE 0
           END) AS legitimate_transactions,
       ROUND(100.0 * SUM(CASE
                             WHEN "isFraud" = 1 THEN 1
                             ELSE 0
                         END) / COUNT(*), 2) AS fraud_rate_percent
FROM public.train_transactions;

-- ============================================================
-- 3. DUPLICATE TRANSACTION IDs
-- ============================================================

SELECT "TransactionID",
       COUNT(*) AS occurrence_count
FROM public.train_transactions
GROUP BY "TransactionID"
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- ============================================================
-- 4. MISSING VALUES IN IMPORTANT COLUMNS
-- ============================================================

SELECT COUNT(*) AS total_rows,
       COUNT(*) - COUNT("TransactionID") AS missing_transaction_id,
       COUNT(*) - COUNT("TransactionAmt") AS missing_transaction_amount,
       COUNT(*) - COUNT("ProductCD") AS missing_product_cd,
       COUNT(*) - COUNT("card4") AS missing_card_type,
       COUNT(*) - COUNT("card6") AS missing_card_category,
       COUNT(*) - COUNT("isFraud") AS missing_fraud_label
FROM public.train_transactions;

-- ============================================================
-- 5. TRANSACTION AMOUNT QUALITY
-- ============================================================

SELECT MIN("TransactionAmt") AS minimum_amount,
       MAX("TransactionAmt") AS maximum_amount,
       ROUND(AVG("TransactionAmt")::numeric, 2) AS average_amount,
       COUNT(*) FILTER (
                        WHERE "TransactionAmt" <= 0) AS non_positive_amounts
FROM public.train_transactions;

-- ============================================================
-- 6. FRAUD LABEL VALIDATION
-- ============================================================

SELECT "isFraud",
       COUNT(*) AS transaction_count
FROM public.train_transactions
GROUP BY "isFraud"
ORDER BY "isFraud";

-- ============================================================
-- 7. TRANSACTION DATE/TIME RANGE
-- ============================================================

SELECT MIN("TransactionDT") AS earliest_transaction,
       MAX("TransactionDT") AS latest_transaction,
       COUNT(*) FILTER (
                        WHERE "TransactionDT" IS NULL) AS missing_transaction_time
FROM public.train_transactions;

-- ============================================================
-- 8. IMPORTANT CATEGORICAL VALUES
-- ============================================================

SELECT 'ProductCD' AS column_name,
       COUNT(DISTINCT "ProductCD") AS distinct_values
FROM public.train_transactions
UNION ALL
SELECT 'card4',
       COUNT(DISTINCT "card4")
FROM public.train_transactions
UNION ALL
SELECT 'card6',
       COUNT(DISTINCT "card6")
FROM public.train_transactions;