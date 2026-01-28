-- 02_rules_and_view.sql
-- Fraud rules and combined rule-based view

/* RULE 1 — Detect Rapid Multiple Transactions (≥5 in 10 Minutes)
Fraud scenario: A stolen card making fast purchases before the owner blocks it.*/

WITH tx_window AS (
    SELECT
        transaction_id,
        user_id,
        transaction_time,
        amount,
        COUNT(*) OVER (
            PARTITION BY user_id
            ORDER BY transaction_time
            RANGE BETWEEN INTERVAL '10 minutes' PRECEDING AND CURRENT ROW
        ) AS tx_in_10min
    FROM transactions
)
SELECT *
FROM tx_window
WHERE tx_in_10min >= 5
ORDER BY user_id, transaction_time;

/* RULE 2 — “Impossible Travel” Fraud
Same user appears in two different countries with very little time gap between transactions → physically impossible → suspicious.*/

WITH user_moves AS (
    SELECT
        transaction_id,
        user_id,
        country,
        transaction_time,
        LAG(country) OVER (PARTITION BY user_id ORDER BY transaction_time) AS prev_country,
        LAG(transaction_time) OVER (PARTITION BY user_id ORDER BY transaction_time) AS prev_time
    FROM transactions
),
suspicious_travel AS (
    SELECT
        transaction_id,
        user_id,
        country,
        prev_country,
        transaction_time,
        prev_time,
        EXTRACT(EPOCH FROM (transaction_time - prev_time)) / 3600.0 AS hours_diff
    FROM user_moves
    WHERE prev_country IS NOT NULL
      AND country <> prev_country
)
SELECT *
FROM suspicious_travel
WHERE hours_diff < 3  -- less than 3 hours between different countries
ORDER BY user_id, transaction_time;

/* RULE 3 — Night-Time High-Amount Transactions
Frauds often happen late night when user is sleeping.*/

SELECT
    transaction_id,
    user_id,
    transaction_time,
    amount,
    country,
    merchant_category
FROM transactions
WHERE EXTRACT(HOUR FROM transaction_time) BETWEEN 0 AND 4
  AND amount > 150
ORDER BY transaction_time;

/* Create a View that Combines All Rules */

CREATE OR REPLACE VIEW rule_based_fraud_flags AS
WITH rapid AS (
    SELECT
        transaction_id,
        COUNT(*) OVER (
            PARTITION BY user_id
            ORDER BY transaction_time
            RANGE BETWEEN INTERVAL '10 minutes' PRECEDING AND CURRENT ROW
        ) AS tx_in_10min
    FROM transactions
),
travel AS (
    SELECT
        transaction_id,
        country,
        LAG(country) OVER (PARTITION BY user_id ORDER BY transaction_time) AS prev_country,
        LAG(transaction_time) OVER (PARTITION BY user_id ORDER BY transaction_time) AS prev_time,
        EXTRACT(
            EPOCH FROM (
                transaction_time
                - LAG(transaction_time) OVER (PARTITION BY user_id ORDER BY transaction_time)
            )
        ) / 3600.0 AS hours_diff
    FROM transactions
),
night AS (
    SELECT
        transaction_id,
        CASE
            WHEN EXTRACT(HOUR FROM transaction_time) BETWEEN 0 AND 4
                 AND amount > 150
            THEN 1 ELSE 0
        END AS flag_night_high_amount
    FROM transactions
)
SELECT
    t.*,
    -- Rule 1: rapid transactions
    CASE
        WHEN r.tx_in_10min >= 5 THEN 1 ELSE 0
    END AS flag_rapid_tx,

    -- Rule 2: impossible travel
    CASE
        WHEN tr.prev_country IS NOT NULL
             AND tr.country <> tr.prev_country
             AND tr.hours_diff < 3
        THEN 1 ELSE 0
    END AS flag_impossible_travel,

    -- Rule 3: night-time high amount
    n.flag_night_high_amount,

    -- Overall flag: if any rule fired
    CASE
        WHEN
            (CASE WHEN r.tx_in_10min >= 5 THEN 1 ELSE 0 END)
          + (CASE WHEN tr.prev_country IS NOT NULL
                        AND tr.country <> tr.prev_country
                        AND tr.hours_diff < 3
                  THEN 1 ELSE 0 END)
          + COALESCE(n.flag_night_high_amount, 0)
        > 0
        THEN 1 ELSE 0
    END AS is_flagged_by_rules
FROM transactions t
LEFT JOIN rapid  r  USING (transaction_id)
LEFT JOIN travel tr USING (transaction_id)
LEFT JOIN night  n  USING (transaction_id);

-- Quick check of the view
SELECT * FROM rule_based_fraud_flags
LIMIT 5;
