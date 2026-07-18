# Healthcare Claims Fraud Detection

A rule-based fraud detection project analyzing 10,000 healthcare insurance claims — no ML, just data-driven pattern discovery and SQL-based risk scoring.

## Overview
This project investigates which factors actually correlate with fraudulent healthcare claims, moving from initial hypotheses (provider specialty, insurance type, patient state) to the signals that turned out to matter (billing gaps, submission timing, and provider claim volume).

## Approach
1. **Python** — Data cleaning: null checks, duplicate detection, type fixes, and range/logic validation on 10,000 claims
2. **PostgreSQL** — Exploratory analysis and rule-based fraud risk scoring using SQL aggregations and `CASE WHEN` logic
3. **Power BI** — Interactive dashboard visualizing fraud trends, risk distribution, and flagged providers

## Dashboard Preview
![Dashboard](powerbi/dashboard_page-0001.jpg)

## Key Findings
- **Weak predictors:** Provider specialty (6.99%–9.69% fraud rate), insurance type (8.23%–8.45%), and patient state (7.50%–9.50%) showed only narrow variation — not reliable standalone fraud indicators
- **Strong predictors:**
  - **Claim-to-Approved Gap:** Fraudulent claims averaged a ~$445 gap vs. ~$66 for legitimate claims (6.8x higher)
  - **Submission Speed:** Fraudulent claims were filed ~3 days after service on average vs. ~15 days for legitimate claims
  - **Provider Claim Volume:** Providers with 100+ claims/month had a 23.3% fraud rate vs. 6.8% for low-volume providers

## Risk Scoring Rule
Combined the three strong signals into a simple SQL-based risk classification:
- **High Risk:** All 3 conditions met (gap > $200 AND days ≤ 6 AND volume ≥ 100)
- **Medium Risk:** 1–2 conditions met
- **Low Risk:** None met

**Validation:** High Risk claims showed a 97.76% actual fraud rate; Low Risk claims showed 0% — a strong result, though likely amplified by the dataset being synthetic. Treat findings as directionally sound rather than production-ready thresholds.

## Folder Structure
data/     → Raw and cleaned CSV files
eda/      → Python cleaning & exploration notebook
sql/      → PostgreSQL scripts (exploration queries + risk scoring logic)
powerbi/  → Power BI dashboard file (.pbix), PDF export, and preview image

## Dashboard Features
- KPI cards (total claims, fraud rate, claim amount, exposure)
- Fraud rate & claim volume trend over time
- Risk level distribution (donut chart)
- Top flagged providers table
- Fraud rate breakdowns by specialty, gender, and insurance type

## Tools Used
Python (pandas) · PostgreSQL · Power BI

## Note
Dataset is synthetic. Findings demonstrate methodology and analytical reasoning rather than real-world production accuracy.
