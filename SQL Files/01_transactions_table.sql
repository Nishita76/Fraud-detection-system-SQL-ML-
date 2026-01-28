-- 01_create_and_check.sql
-- Create base transactions table and simple checks

CREATE TABLE transactions (
    transaction_id      SERIAL PRIMARY KEY,
    user_id             INT,
    transaction_time    TIMESTAMP,
    amount              NUMERIC(10,2),
    country             VARCHAR(50),
    merchant_category   VARCHAR(50),
    device_id           VARCHAR(50),
    ip_address          VARCHAR(50),
    is_fraud_label      BOOLEAN,
    created_at          TIMESTAMP DEFAULT NOW()
);

-- Row count check
SELECT COUNT(*) FROM transactions;

-- Sample rows
SELECT * FROM transactions LIMIT 5;
