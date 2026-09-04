-- ============================================================
-- FRAUD & TRANSACTION RISK INTELLIGENCE
-- BEHAVIOURAL ANALYSIS
-- ============================================================


-- 1. Transaction behaviour by ProductCD

SELECT
    "ProductCD",
    COUNT(*) AS total_transactions,
    ROUND(AVG("TransactionAmt")::numeric, 2) AS average_transaction_amount,
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        SUM("isFraud") * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY "ProductCD"
ORDER BY fraud_rate_percentage DESC;


-- 2. Transaction behaviour by card type

SELECT
    "card4",
    COUNT(*) AS total_transactions,
    ROUND(AVG("TransactionAmt")::numeric, 2) AS average_transaction_amount,
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        SUM("isFraud") * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM public.train_transactions
WHERE "card4" IS NOT NULL
GROUP BY "card4"
ORDER BY fraud_rate_percentage DESC;


-- 3. Transaction behaviour by card category

SELECT
    "card6",
    COUNT(*) AS total_transactions,
    ROUND(AVG("TransactionAmt")::numeric, 2) AS average_transaction_amount,
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        SUM("isFraud") * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM public.train_transactions
WHERE "card6" IS NOT NULL
GROUP BY "card6"
ORDER BY fraud_rate_percentage DESC;


-- 4. Fraud behaviour by transaction hour

SELECT
    EXTRACT(
        HOUR FROM
        TIMESTAMP '1970-01-01'
        + ("TransactionDT" * INTERVAL '1 second')
    ) AS transaction_hour,
    COUNT(*) AS total_transactions,
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        SUM("isFraud") * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY transaction_hour
ORDER BY transaction_hour;


-- 5. Transaction volume by hour

SELECT
    EXTRACT(
        HOUR FROM
        TIMESTAMP '1970-01-01'
        + ("TransactionDT" * INTERVAL '1 second')
    ) AS transaction_hour,
    COUNT(*) AS transaction_count,
    ROUND(
        AVG("TransactionAmt")::numeric,
        2
    ) AS average_transaction_amount
FROM public.train_transactions
GROUP BY transaction_hour
ORDER BY transaction_hour;


-- 6. Fraud behaviour by transaction day

SELECT
    EXTRACT(
        DOW FROM
        TIMESTAMP '1970-01-01'
        + ("TransactionDT" * INTERVAL '1 second')
    ) AS day_of_week,
    COUNT(*) AS total_transactions,
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        SUM("isFraud") * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY day_of_week
ORDER BY day_of_week;


-- 7. Behaviour of high-value transactions

SELECT
    CASE
        WHEN "TransactionAmt" >= 500 THEN 'High Value'
        ELSE 'Standard Value'
    END AS transaction_type,
    COUNT(*) AS total_transactions,
    ROUND(AVG("TransactionAmt")::numeric, 2) AS average_amount,
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        SUM("isFraud") * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY transaction_type
ORDER BY fraud_rate_percentage DESC;


-- 8. Fraud behaviour across transaction amount ranges

SELECT
    CASE
        WHEN "TransactionAmt" < 50 THEN 'Under 50'
        WHEN "TransactionAmt" < 100 THEN '50-99'
        WHEN "TransactionAmt" < 250 THEN '100-249'
        WHEN "TransactionAmt" < 500 THEN '250-499'
        WHEN "TransactionAmt" < 1000 THEN '500-999'
        ELSE '1000+'
    END AS amount_band,
    COUNT(*) AS total_transactions,
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        AVG("TransactionAmt")::numeric,
        2
    ) AS average_amount,
    ROUND(
        SUM("isFraud") * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY amount_band
ORDER BY MIN("TransactionAmt");


-- 9. Product + card behaviour

SELECT
    "ProductCD",
    "card4",
    COUNT(*) AS total_transactions,
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        SUM("isFraud") * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM public.train_transactions
WHERE "ProductCD" IS NOT NULL
  AND "card4" IS NOT NULL
GROUP BY "ProductCD", "card4"
HAVING COUNT(*) >= 100
ORDER BY fraud_rate_percentage DESC;


-- 10. Product + card category behaviour

SELECT
    "ProductCD",
    "card6",
    COUNT(*) AS total_transactions,
    ROUND(AVG("TransactionAmt")::numeric, 2) AS average_amount,
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        SUM("isFraud") * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM public.train_transactions
WHERE "ProductCD" IS NOT NULL
  AND "card6" IS NOT NULL
GROUP BY "ProductCD", "card6"
HAVING COUNT(*) >= 100
ORDER BY fraud_rate_percentage DESC;


-- 11. Behaviour of the most frequently used card types

SELECT
    "card4",
    COUNT(*) AS transaction_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS transaction_share_percentage
FROM public.train_transactions
WHERE "card4" IS NOT NULL
GROUP BY "card4"
ORDER BY transaction_count DESC;


-- 12. Fraud concentration by product

SELECT
    "ProductCD",
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        SUM("isFraud") * 100.0 /
        SUM(SUM("isFraud")) OVER (),
        2
    ) AS share_of_all_fraud_percentage
FROM public.train_transactions
GROUP BY "ProductCD"
ORDER BY fraudulent_transactions DESC;


-- 13. Overall behavioural risk summary

SELECT
    "ProductCD",
    COUNT(*) AS total_transactions,
    SUM("isFraud") AS fraudulent_transactions,
    ROUND(
        AVG("TransactionAmt")::numeric,
        2
    ) AS average_transaction_amount,
    ROUND(
        SUM("isFraud") * 100.0 / COUNT(*),
        2
    ) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY "ProductCD"
ORDER BY fraudulent_transactions DESC;