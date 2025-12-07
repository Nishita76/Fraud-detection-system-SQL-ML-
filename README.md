# AI-Assisted Fraud Detection System (SQL + Machine Learning)
A real-world style project that simulates how banks and fintech companies detect fraudulent financial transactions.

This project combines:
- **Rule-Based Fraud Detection using SQL**
- **Machine Learning Fraud Prediction using Python**
- **Cloud-hosted PostgreSQL database (Neon)**

## Tech Stack

- **Database:** PostgreSQL (Neon Cloud)
- **Languages:** SQL, Python
- **Libraries:** pandas, SQLAlchemy, scikit-learn
- **Tools:** Google Colab

---

## Project Structure

- `fraud_detection_sql_ai.ipynb` → Colab notebook for data generation + ML model  
- `01_transactions_table.sql` → SQL script to create `transactions` table  
- `02_rules_and_view.sql` → SQL view with 3 fraud rules  
- `03_summary_and_ml_checks.sql` → SQL queries for fraud analytics & performance summary  

---

## Rule-Based Fraud Detection (SQL)

The **SQL rule engine** uses:

1. **Rapid Transactions Rule**  
   - Flags users with ≥5 transactions in a 10-minute window

2. **Impossible Travel Rule**  
   - Flags users who appear in two different countries within 3 hours

3. **Night-Time High-Amount Rule**  
   - Flags transactions between 00:00–04:00 with high amounts

All rules are combined in a view: `rule_based_fraud_flags`.

Example outputs:
- `total_transactions` ≈ 50,000  
- `total_any_rule_flags` ≈ 43,498 (≈87% of all transactions flagged by at least one rule)

---

## 🤖 ML Fraud Prediction (Python)

I trained a **RandomForest classifier** on:

- `amount`
- `country`
- `merchant_category`
- `hour of transaction`

Target: `is_fraud_label` (True/False)

The model achieved:

- **Accuracy:** ~99.99%  
- **Very high recall for fraud cases** (only 2 missed frauds in the test set)  
- **Zero false positives** in the test set

This demonstrates how **AI can improve upon static SQL rules**, especially by reducing unnecessary alerts.

---

## Key Learnings

- How to design a fraud rules engine using **window functions, CTEs, and time logic** in SQL  
- How to host PostgreSQL in the **cloud (Neon)** and connect via Python  
- How to build a simple but powerful **ML model** and compare it against SQL-based rules  
- How SQL and AI can work **together** in real-world fraud detection systems

---

## Future Improvements

- Add more behavior-based features (device fingerprint, merchant risk level)
- Deploy a simple dashboard for fraud monitoring (Power BI / Tableau)
