-- ============================================================
-- FRAUD & TRANSACTION RISK INTELLIGENCE
-- TRANSACTION ANALYSIS
-- ============================================================
 -- 1. Transaction amount overview

SELECT COUNT(*) AS total_transactions,
       ROUND(AVG("TransactionAmt")::numeric, 2) AS average_transaction_amount,
       MIN("TransactionAmt") AS minimum_transaction_amount,
       MAX("TransactionAmt") AS maximum_transaction_amount,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (
                                                ORDER BY "TransactionAmt")::numeric, 2) AS median_transaction_amount
FROM public.train_transactions;

-- 2. Fraud vs legitimate transactions

SELECT "isFraud",
       COUNT(*) AS transaction_count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_transactions
FROM public.train_transactions
GROUP BY "isFraud"
ORDER BY "isFraud";

-- 3. Fraud rate

SELECT COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions;

-- 4. Transaction amount: fraud vs legitimate

SELECT "isFraud",
       COUNT(*) AS transaction_count,
       ROUND(AVG("TransactionAmt")::numeric, 2) AS average_amount,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (
                                                ORDER BY "TransactionAmt")::numeric, 2) AS median_amount,
       ROUND(MAX("TransactionAmt")::numeric, 2) AS maximum_amount
FROM public.train_transactions
GROUP BY "isFraud"
ORDER BY "isFraud";

-- 5. Fraud by product category

SELECT "ProductCD",
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY "ProductCD"
ORDER BY fraud_rate_percentage DESC;

-- 6. Fraud by card type

SELECT "card4",
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
WHERE "card4" IS NOT NULL
GROUP BY "card4"
ORDER BY fraud_rate_percentage DESC;

-- 7. Fraud by card category

SELECT "card6",
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
WHERE "card6" IS NOT NULL
GROUP BY "card6"
ORDER BY fraud_rate_percentage DESC;

-- 8. Fraud by email domain

SELECT "P_emaildomain",
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
WHERE "P_emaildomain" IS NOT NULL
GROUP BY "P_emaildomain"
HAVING COUNT(*) >= 100
ORDER BY fraud_rate_percentage DESC
LIMIT 20;

-- 9. Fraud by transaction time

SELECT EXTRACT(HOUR
               FROM TIMESTAMP '1970-01-01' + ("TransactionDT" * INTERVAL '1 second')) AS transaction_hour,
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY transaction_hour
ORDER BY transaction_hour;

-- 10. High-value transactions

SELECT "TransactionID",
       "TransactionAmt",
       "ProductCD",
       "card4",
       "card6",
       "isFraud"
FROM public.train_transactions
ORDER BY "TransactionAmt" DESC
LIMIT 20;

-- 11. Highest-value fraudulent transactions

SELECT "TransactionID",
       "TransactionAmt",
       "ProductCD",
       "card4",
       "card6",
       "isFraud"
FROM public.train_transactions
WHERE "isFraud" = 1
ORDER BY "TransactionAmt" DESC
LIMIT 20;

-- 12. Transaction amount bands

SELECT CASE
           WHEN "TransactionAmt" < 50 THEN 'Under 50'
           WHEN "TransactionAmt" < 100 THEN '50-99'
           WHEN "TransactionAmt" < 250 THEN '100-249'
           WHEN "TransactionAmt" < 500 THEN '250-499'
           WHEN "TransactionAmt" < 1000 THEN '500-999'
           ELSE '1000+'
       END AS amount_band,
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY amount_band
ORDER BY MIN("TransactionAmt");

-- 13. Overall transaction risk summary

SELECT COUNT(*) AS total_transactions,
       SUM("isFraud") AS total_fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS overall_fraud_rate,
       ROUND(SUM(CASE
                     WHEN "isFraud" = 1 THEN "TransactionAmt"
                     ELSE 0
                 END)::numeric, 2) AS fraudulent_transaction_value,
       ROUND(SUM("TransactionAmt")::numeric, 2) AS total_transaction_value
FROM public.train_transactions;