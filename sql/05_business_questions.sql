-- ============================================================
-- FRAUD & TRANSACTION RISK INTELLIGENCE
-- BUSINESS QUESTIONS
-- ============================================================
 -- ============================================================
-- BUSINESS QUESTION 1
-- What is the overall fraud rate?
-- ============================================================

SELECT COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions;

-- ============================================================
-- BUSINESS QUESTION 2
-- Which product categories have the highest fraud rate?
-- ============================================================

SELECT "ProductCD",
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY "ProductCD"
ORDER BY fraud_rate_percentage DESC;

-- ============================================================
-- BUSINESS QUESTION 3
-- Which card types show the highest fraud risk?
-- ============================================================

SELECT "card4",
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
WHERE "card4" IS NOT NULL
GROUP BY "card4"
HAVING COUNT(*) >= 100
ORDER BY fraud_rate_percentage DESC;

-- ============================================================
-- BUSINESS QUESTION 4
-- Are high-value transactions more likely to be fraudulent?
-- ============================================================

SELECT CASE
           WHEN "TransactionAmt" >= 1000 THEN 'High Value'
           ELSE 'Standard Value'
       END AS transaction_value_group,
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage,
       ROUND(AVG("TransactionAmt")::numeric, 2) AS average_transaction_amount
FROM public.train_transactions
GROUP BY CASE
             WHEN "TransactionAmt" >= 1000 THEN 'High Value'
             ELSE 'Standard Value'
         END
ORDER BY fraud_rate_percentage DESC;

-- ============================================================
-- BUSINESS QUESTION 5
-- Which transaction amount range has the highest fraud rate?
-- ============================================================

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
GROUP BY CASE
             WHEN "TransactionAmt" < 50 THEN 'Under 50'
             WHEN "TransactionAmt" < 100 THEN '50-99'
             WHEN "TransactionAmt" < 250 THEN '100-249'
             WHEN "TransactionAmt" < 500 THEN '250-499'
             WHEN "TransactionAmt" < 1000 THEN '500-999'
             ELSE '1000+'
         END
ORDER BY MIN("TransactionAmt");

-- ============================================================
-- BUSINESS QUESTION 6
-- During which hours does fraud occur most frequently?
-- ============================================================

SELECT EXTRACT(HOUR
               FROM TIMESTAMP '1970-01-01' + ("TransactionDT" * INTERVAL '1 second')) AS transaction_hour,
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY transaction_hour
ORDER BY fraud_rate_percentage DESC;

-- ============================================================
-- BUSINESS QUESTION 7
-- Which product + card combinations have elevated fraud risk?
-- ============================================================

SELECT "ProductCD",
       "card4",
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
WHERE "ProductCD" IS NOT NULL
    AND "card4" IS NOT NULL
GROUP BY "ProductCD",
         "card4"
HAVING COUNT(*) >= 100
ORDER BY fraud_rate_percentage DESC;

-- ============================================================
-- BUSINESS QUESTION 8
-- Which transactions should be prioritized for investigation?
-- ============================================================

SELECT "TransactionID",
       "TransactionAmt",
       "ProductCD",
       "card4",
       "card6",
       "isFraud"
FROM public.train_transactions
WHERE "TransactionAmt" >= 1000
ORDER BY "TransactionAmt" DESC
LIMIT 50;

-- ============================================================
-- BUSINESS QUESTION 9
-- How much transaction value is associated with fraud?
-- ============================================================

SELECT COUNT(*) AS total_transactions,
       ROUND(SUM("TransactionAmt")::numeric, 2) AS total_transaction_value,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM(CASE
                     WHEN "isFraud" = 1 THEN "TransactionAmt"
                     ELSE 0
                 END)::numeric, 2) AS fraudulent_transaction_value,
       ROUND((SUM(CASE
                      WHEN "isFraud" = 1 THEN "TransactionAmt"
                      ELSE 0
                  END) * 100.0 / SUM("TransactionAmt"))::numeric, 2) AS fraud_value_percentage
FROM public.train_transactions;

-- ============================================================
-- BUSINESS QUESTION 10
-- Where should the fraud team prioritize attention?
-- ============================================================
 WITH risk_segments AS
    (SELECT CASE
                WHEN "TransactionAmt" >= 1000 THEN 'High Risk'
                WHEN "TransactionAmt" >= 250 THEN 'Medium Risk'
                ELSE 'Low Risk'
            END AS risk_segment,
            "TransactionAmt",
            "isFraud"
     FROM public.train_transactions)
SELECT risk_segment,
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage,
       ROUND(SUM("TransactionAmt")::numeric, 2) AS transaction_value
FROM risk_segments
GROUP BY risk_segment
ORDER BY fraud_rate_percentage DESC;

-- ============================================================
-- BUSINESS QUESTION 11
-- What are the top product categories by fraudulent value?
-- ============================================================

SELECT "ProductCD",
       COUNT(*) AS fraudulent_transactions,
       ROUND(SUM("TransactionAmt")::numeric, 2) AS fraudulent_transaction_value,
       ROUND(AVG("TransactionAmt")::numeric, 2) AS average_fraudulent_amount
FROM public.train_transactions
WHERE "isFraud" = 1
GROUP BY "ProductCD"
ORDER BY fraudulent_transaction_value DESC;

-- ============================================================
-- BUSINESS QUESTION 12
-- Executive fraud-risk summary
-- ============================================================

SELECT COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage,
       ROUND(SUM("TransactionAmt")::numeric, 2) AS total_transaction_value,
       ROUND(SUM(CASE
                     WHEN "isFraud" = 1 THEN "TransactionAmt"
                     ELSE 0
                 END)::numeric, 2) AS fraudulent_transaction_value,
       ROUND(AVG("TransactionAmt")::numeric, 2) AS average_transaction_amount,
       ROUND(AVG(CASE
                     WHEN "isFraud" = 1 THEN "TransactionAmt"
                 END)::numeric, 2) AS average_fraudulent_amount
FROM public.train_transactions;