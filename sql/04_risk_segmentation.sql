-- ============================================================
-- FRAUD & TRANSACTION RISK INTELLIGENCE
-- RISK SEGMENTATION
-- ============================================================
 -- 1. Basic risk segmentation

SELECT "TransactionID",
       "TransactionAmt",
       "ProductCD",
       "card4",
       "card6",
       "isFraud",
       CASE
           WHEN "TransactionAmt" >= 1000 THEN 'High Risk'
           WHEN "TransactionAmt" >= 250 THEN 'Medium Risk'
           ELSE 'Low Risk'
       END AS risk_segment
FROM public.train_transactions;

-- 2. Risk segment summary

SELECT CASE
           WHEN "TransactionAmt" >= 1000 THEN 'High Risk'
           WHEN "TransactionAmt" >= 250 THEN 'Medium Risk'
           ELSE 'Low Risk'
       END AS risk_segment,
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage,
       ROUND(AVG("TransactionAmt")::numeric, 2) AS average_transaction_amount
FROM public.train_transactions
GROUP BY CASE
             WHEN "TransactionAmt" >= 1000 THEN 'High Risk'
             WHEN "TransactionAmt" >= 250 THEN 'Medium Risk'
             ELSE 'Low Risk'
         END
ORDER BY MIN("TransactionAmt") DESC;

-- 3. Fraud concentration by risk segment

SELECT CASE
           WHEN "TransactionAmt" >= 1000 THEN 'High Risk'
           WHEN "TransactionAmt" >= 250 THEN 'Medium Risk'
           ELSE 'Low Risk'
       END AS risk_segment,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / SUM(SUM("isFraud")) OVER (), 2) AS share_of_all_fraud_percentage
FROM public.train_transactions
GROUP BY CASE
             WHEN "TransactionAmt" >= 1000 THEN 'High Risk'
             WHEN "TransactionAmt" >= 250 THEN 'Medium Risk'
             ELSE 'Low Risk'
         END
ORDER BY fraudulent_transactions DESC;

-- 4. High-risk transaction profile

SELECT "ProductCD",
       "card4",
       "card6",
       COUNT(*) AS high_risk_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage,
       ROUND(AVG("TransactionAmt")::numeric, 2) AS average_transaction_amount
FROM public.train_transactions
WHERE "TransactionAmt" >= 1000
GROUP BY "ProductCD",
         "card4",
         "card6"
HAVING COUNT(*) >= 20
ORDER BY fraud_rate_percentage DESC;

-- 5. Risk segmentation by product

SELECT "ProductCD",
       CASE
           WHEN "TransactionAmt" >= 1000 THEN 'High Risk'
           WHEN "TransactionAmt" >= 250 THEN 'Medium Risk'
           ELSE 'Low Risk'
       END AS risk_segment,
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
GROUP BY "ProductCD",
         CASE
             WHEN "TransactionAmt" >= 1000 THEN 'High Risk'
             WHEN "TransactionAmt" >= 250 THEN 'Medium Risk'
             ELSE 'Low Risk'
         END
ORDER BY "ProductCD",
         fraud_rate_percentage DESC;

-- 6. Risk segmentation by card type

SELECT "card4",
       CASE
           WHEN "TransactionAmt" >= 1000 THEN 'High Risk'
           WHEN "TransactionAmt" >= 250 THEN 'Medium Risk'
           ELSE 'Low Risk'
       END AS risk_segment,
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM public.train_transactions
WHERE "card4" IS NOT NULL
GROUP BY "card4",
         CASE
             WHEN "TransactionAmt" >= 1000 THEN 'High Risk'
             WHEN "TransactionAmt" >= 250 THEN 'Medium Risk'
             ELSE 'Low Risk'
         END
ORDER BY "card4",
         fraud_rate_percentage DESC;

-- 7. Risk score

SELECT "TransactionID",
       "TransactionAmt",
       "ProductCD",
       "card4",
       "card6",
       "isFraud",
       (CASE
            WHEN "TransactionAmt" >= 1000 THEN 2
            WHEN "TransactionAmt" >= 250 THEN 1
            ELSE 0
        END + CASE
                  WHEN "ProductCD" IN ('C',
                                       'S') THEN 1
                  ELSE 0
              END + CASE
                        WHEN "card6" = 'credit' THEN 1
                        ELSE 0
                    END) AS risk_score
FROM public.train_transactions;

-- 8. Final risk classification
 WITH risk_data AS
    (SELECT "TransactionID",
            "TransactionAmt",
            "ProductCD",
            "card4",
            "card6",
            "isFraud",
            (CASE
                 WHEN "TransactionAmt" >= 1000 THEN 2
                 WHEN "TransactionAmt" >= 250 THEN 1
                 ELSE 0
             END + CASE
                       WHEN "ProductCD" IN ('C',
                                            'S') THEN 1
                       ELSE 0
                   END + CASE
                             WHEN "card6" = 'credit' THEN 1
                             ELSE 0
                         END) AS risk_score
     FROM public.train_transactions)
SELECT "TransactionID",
       "TransactionAmt",
       "ProductCD",
       "card4",
       "card6",
       "isFraud",
       risk_score,
       CASE
           WHEN risk_score >= 3 THEN 'High Risk'
           WHEN risk_score = 2 THEN 'Medium Risk'
           ELSE 'Low Risk'
       END AS risk_segment
FROM risk_data;

-- 9. Risk segment performance
 WITH risk_data AS
    (SELECT "TransactionAmt",
            "isFraud",
            (CASE
                 WHEN "TransactionAmt" >= 1000 THEN 2
                 WHEN "TransactionAmt" >= 250 THEN 1
                 ELSE 0
             END + CASE
                       WHEN "ProductCD" IN ('C',
                                            'S') THEN 1
                       ELSE 0
                   END + CASE
                             WHEN "card6" = 'credit' THEN 1
                             ELSE 0
                         END) AS risk_score
     FROM public.train_transactions)
SELECT CASE
           WHEN risk_score >= 3 THEN 'High Risk'
           WHEN risk_score = 2 THEN 'Medium Risk'
           ELSE 'Low Risk'
       END AS risk_segment,
       COUNT(*) AS total_transactions,
       SUM("isFraud") AS fraudulent_transactions,
       ROUND(SUM("isFraud") * 100.0 / COUNT(*), 2) AS fraud_rate_percentage,
       ROUND(SUM("TransactionAmt")::numeric, 2) AS total_transaction_value
FROM risk_data
GROUP BY CASE
             WHEN risk_score >= 3 THEN 'High Risk'
             WHEN risk_score = 2 THEN 'Medium Risk'
             ELSE 'Low Risk'
         END
ORDER BY total_transaction_value DESC;