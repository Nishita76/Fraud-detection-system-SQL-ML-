-- 03_summary_and_ml_checks.sql
-- Summary analytics and comparison of rules vs labels & ML output

-- Overall rule flag summary
SELECT
    SUM(flag_rapid_tx)              AS total_rapid_flags,
    SUM(flag_impossible_travel)     AS total_travel_flags,
    SUM(flag_night_high_amount)     AS total_night_flags,
    SUM(is_flagged_by_rules)        AS total_any_rule_flags,
    COUNT(*)                        AS total_transactions
FROM rule_based_fraud_flags;

/* Compare Rules vs True Fraud Label */

SELECT
    is_fraud_label,
    is_flagged_by_rules,
    COUNT(*) AS count_rows
FROM rule_based_fraud_flags
GROUP BY is_fraud_label, is_flagged_by_rules
ORDER BY is_fraud_label, is_flagged_by_rules;

-- Check ML predictions table (created from Python)
SELECT COUNT(*) FROM ml_predictions;
SELECT * FROM ml_predictions LIMIT 5;
