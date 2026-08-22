# Fraud & Transaction Risk Intelligence

An end-to-end fraud analytics and risk intelligence project combining Python, SQL, machine learning and Power BI to identify suspicious transaction behaviour, prioritize investigations and analyze potential financial exposure.

## 🎯 Business Problem

Fraud detection is not simply a classification problem.

Financial institutions must identify suspicious transactions while balancing:

- Fraud detection
- False positives
- Investigation capacity
- Transaction exposure
- Operational efficiency

This project develops an analytical decision-support system to help answer:

> Which transactions should be investigated first?

## 🔄 Data Pipeline & Project Workflow

This project follows an end-to-end data and machine learning pipeline that transforms raw transaction data into actionable fraud risk insights.

```text
Raw IEEE-CIS Dataset
        │
        ▼
01. Data Preparation
        │
        ▼
02. Fraud EDA
        │
        ▼
03. Feature Engineering
        │
        ▼
04. Fraud Modelling
        │
        ▼
05. Model Evaluation
        │
        ▼
06. Risk Analysis
        │
        ▼
Fraud Risk Insights
```

## 🛠️ Tech Stack

- Python
- Pandas
- NumPy
- Scikit-learn
- XGBoost
- SQL
- Power BI
- Git/GitHub

## 📊 Dataset

IEEE-CIS Fraud Detection dataset.

The dataset contains transaction and identity information and includes a binary fraud target.

Raw data is not included in this repository because of its size and dataset licensing/usage considerations.

## 📈 Dashboard

Coming soon.

## 🤖 Machine Learning

Models will be evaluated using metrics appropriate for imbalanced fraud detection:

- Precision
- Recall
- F1-score
- ROC-AUC
- PR-AUC

Accuracy will not be used as the primary evaluation metric.

## 🗄️ SQL

SQL will be used for:

- Transaction analysis
- Behavioural analysis
- Aggregations
- Customer/transaction summaries
- Risk segmentation
- Business questions
- Window-function analysis

## ⚠️ Disclaimer

This project is an analytical decision-support prototype and is not intended for production fraud detection or financial decision-making.

## 📁 Project Structure

```text
fraud-transaction-risk-intelligence/
├── data/
├── sql/
├── notebooks/
├── src/
├── models/
├── reports/
├── powerbi/
├── README.md
└── requirements.txt
