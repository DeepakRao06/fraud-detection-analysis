# 🚨 Fraud Detection Analysis

## 📌 Overview

This project focuses on detecting fraudulent transactions using SQL and Python.
It analyzes transaction patterns like rapid activity, location changes, and unusual spending.

---

## 🎯 Objectives

* Detect suspicious transactions
* Build risk-based features
* Improve fraud detection recall

---

## ⚙️ Tech Stack

* Python (Pandas, NumPy)
* SQL (Window Functions, CTE, Aggregations)
* Scikit-learn (Logistic Regression)

---

## 📂 Project Structure

```
fraud-detection-analysis/
│
├── data/
├── sql/
│   └── analysis.sql
├── src/
│   └── main.py
├── README.md
├── requirements.txt
```

---

## 🔍 SQL Analysis

* Detected rapid transactions using LAG() and TIMESTAMPDIFF
* Identified location changes between transactions
* Found high-value and high-frequency users
* Built risk scoring logic using CTE + CASE

---

## 🤖 Machine Learning

* Built Logistic Regression model
* Created features: time_gap, location_changed, night, risk_score
* Tuned threshold for better fraud detection

---

## 📈 Results

* Accuracy: ~69%
* Fraud Recall: 🔥 ~76%
* Precision: ~57%

---

## 📊 Dataset

Synthetic dataset generated using Python (NumPy & Pandas)

---

## ▶️ How to Run

```
pip install -r requirements.txt
python src/main.py
```

---

## 👨‍💻 Author

Deepak Rao
