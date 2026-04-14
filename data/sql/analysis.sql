-- ============================================================
-- 📊 FRAUD DETECTION SQL ANALYSIS
-- Author: Deepak Rao
-- ============================================================


-- 1️⃣ High Amount Transactions (Above Overall Average)
-- Find transactions where amount is greater than global average

SELECT *
FROM transactions
WHERE amount > (
    SELECT AVG(amount) FROM transactions
);


-- 2️⃣ High Amount vs User Average
-- Compare transaction amount with user’s average spending

SELECT *
FROM (
    SELECT *,
           AVG(amount) OVER (PARTITION BY user_id) AS avg_amount
    FROM transactions
) t
WHERE amount > avg_amount;


-- 3️⃣ Extract Transaction Hour
-- Used for time-based analysis (e.g., night transactions)

SELECT HOUR(timestamp) AS hours
FROM transactions;


-- 4️⃣ Night High-Value Transactions
-- Transactions between 12 AM – 5 AM with high amount

SELECT user_id, amount, transaction_id, HOUR(timestamp) AS hours
FROM transactions
WHERE HOUR(timestamp) BETWEEN 0 AND 5
  AND amount > (SELECT AVG(amount) FROM transactions);


-- 5️⃣ High Frequency Users
-- Users with more than 10 transactions

SELECT user_id, COUNT(*) AS transaction_count
FROM transactions
GROUP BY user_id
HAVING COUNT(*) > 10;


-- 6️⃣ Multi-Location Users
-- Users operating from more than 2 locations

SELECT user_id, COUNT(DISTINCT location) AS location_count
FROM transactions
GROUP BY user_id
HAVING COUNT(DISTINCT location) > 2;


-- 7️⃣ Daily High Activity
-- Users with more than 5 transactions in a day

SELECT user_id,
       DAY(timestamp) AS transaction_day,
       COUNT(*) AS total_transactions
FROM transactions
GROUP BY user_id, DAY(timestamp)
HAVING COUNT(*) > 5;


-- 8️⃣ High Spending Users
-- Users whose total spending is above overall average transaction amount

SELECT user_id, SUM(amount) AS total_amount
FROM transactions
GROUP BY user_id
HAVING SUM(amount) > (
    SELECT AVG(amount) FROM transactions
);


-- 9️⃣ Previous Transaction (Using LAG)
-- Identify previous transaction time for each user

SELECT user_id,
       timestamp,
       LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) AS prev_time
FROM transactions;


-- 🔟 Rapid Transactions (Time Gap < 60 Minutes)
-- Detect transactions happening quickly after previous one

SELECT *
FROM (
    SELECT user_id,
           timestamp AS current_time,
           LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) AS prev_time,
           TIMESTAMPDIFF(MINUTE,
                         LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp),
                         timestamp) AS time_gap
    FROM transactions
) t
WHERE time_gap < 60;


-- 1️⃣1️⃣ Rapid + High Amount Transactions
-- Combine speed + high amount for suspicious behavior

SELECT *
FROM (
    SELECT user_id,
           amount,
           timestamp AS current_time,
           LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) AS prev_time,
           TIMESTAMPDIFF(MINUTE,
                         LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp),
                         timestamp) AS time_gap
    FROM transactions
) t
WHERE time_gap < 60
  AND amount > (SELECT AVG(amount) FROM transactions);


-- 1️⃣2️⃣ Location Change Detection
-- Detect when user changes location between transactions

SELECT *
FROM (
    SELECT user_id,
           timestamp,
           location AS current_location,
           LAG(location) OVER (PARTITION BY user_id ORDER BY timestamp) AS prev_location
    FROM transactions
) t
WHERE prev_location IS NOT NULL
  AND prev_location <> current_location;


-- 1️⃣3️⃣ Risk Scoring System (FINAL LOGIC)
-- Combine multiple factors to calculate fraud risk score

WITH base AS (
    SELECT user_id,
           timestamp,
           location AS current_location,
           amount,
           AVG(amount) OVER () AS average_amount,
           HOUR(timestamp) AS trans_time,
           LAG(location) OVER (PARTITION BY user_id ORDER BY timestamp) AS prev_location,
           LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) AS prev_time
    FROM transactions
),

calculation AS (
    SELECT *,
           TIMESTAMPDIFF(MINUTE, prev_time, timestamp) AS timegap
    FROM base
)

SELECT *,
       (CASE WHEN amount > average_amount THEN 2 ELSE 0 END) +
       (CASE WHEN timegap < 60 THEN 2 ELSE 0 END) +
       (CASE WHEN prev_location <> current_location THEN 1 ELSE 0 END) +
       (CASE WHEN trans_time BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS risk_score
FROM calculation;