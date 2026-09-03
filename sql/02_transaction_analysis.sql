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