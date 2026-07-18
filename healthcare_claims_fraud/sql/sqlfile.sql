-- Healthcare Claims Fraud Detection: SQL Analysis
-- Explores fraud patterns across specialty, insurance, state, billing gap, 
-- submission timing, and provider volume; builds a rule-based risk score.



CREATE TABLE claims (
    Provider_ID VARCHAR,
    Claim_ID VARCHAR,
    Patient_Age INTEGER,
    Patient_Gender VARCHAR,
    Diagnosis_Code VARCHAR,
    Procedure_Code VARCHAR,
    Claim_Amount NUMERIC,
    Approved_Amount NUMERIC,
    Insurance_Type VARCHAR,
    Claim_Submission_Date DATE,
    Days_Between_Service_and_Claim INTEGER,
    Number_of_Claims_Per_Provider_Monthly INTEGER,
    Provider_Specialty VARCHAR,
    Patient_State VARCHAR,
    Claim_Status VARCHAR,
    Is_Fraud INTEGER,
    Length_of_Stay INTEGER,
    Visit_Type VARCHAR,
    Chronic_Condition_Flag INTEGER,
    Prior_Visits_12m NUMERIC
);

---total rows
SELECT count(*) from claims;


--1.check Is_Fraud distribution
SELECT Is_Fraud, COUNT(*), 
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM claims
GROUP BY Is_Fraud;

--2.Which specialties have the highest fraud rate?
SELECT Provider_Specialty, 
       COUNT(*) AS total_claims,
       SUM(Is_Fraud) AS fraud_claims,
       ROUND(100.0 * SUM(Is_Fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM claims
GROUP BY Provider_Specialty
ORDER BY fraud_rate_pct DESC;

--3.Fraud rate by Insurance_Type
SELECT Insurance_type, 
       COUNT(*) AS total_claims,
       SUM(Is_Fraud) AS fraud_claims,
       ROUND(100.0 * SUM(Is_Fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM claims
GROUP BY Insurance_type
ORDER BY fraud_rate_pct DESC;


--4.Fraud rate by Patient_State
SELECT Patient_State,
		COUNT(*) as total_claims,
		sum(Is_Fraud) as fraud_claims,
		ROUND(100.0*SUM(Is_Fraud)/COUNT(*),2) AS fraud_rate_pct
FROM claims
GROUP BY Patient_State
ORDER BY fraud_rate_pct DESC;


--5. Claim vs Approved amount gap
SELECT Is_Fraud, 
       ROUND(AVG(Claim_Amount - Approved_Amount), 2) AS avg_gap,
       ROUND(AVG(Claim_Amount), 2) AS avg_claim,
       ROUND(AVG(Approved_Amount), 2) AS avg_approved
FROM claims
GROUP BY Is_Fraud;


--6a.Providers with unusually high monthly claim counts.
SELECT Provider_ID, Provider_Specialty,
       ROUND(AVG(Number_of_Claims_Per_Provider_Monthly),2) AS avg_monthly_claims,
       COUNT(*) AS total_claims_in_data
FROM claims
GROUP BY Provider_ID, Provider_Specialty
HAVING COUNT(*) >= 10
ORDER BY avg_monthly_claims DESC
LIMIT 15;


--6b. Fraud rate by volume bucket
SELECT 
  CASE 
    WHEN Number_of_Claims_Per_Provider_Monthly >= 100 THEN 'High Volume (100+)'
    WHEN Number_of_Claims_Per_Provider_Monthly >= 70 THEN 'Medium Volume (70-99)'
    ELSE 'Low Volume (<70)'
  END AS volume_bucket,
  COUNT(*) AS total_claims,
  SUM(Is_Fraud) AS fraud_claims,
  ROUND(100.0 * SUM(Is_Fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM claims
GROUP BY volume_bucket
ORDER BY fraud_rate_pct DESC;


--7.Gap between service and claim
SELECT Is_Fraud,
       ROUND(AVG(Days_Between_Service_and_Claim), 2) AS avg_days,
       MIN(Days_Between_Service_and_Claim) AS min_days,
       MAX(Days_Between_Service_and_Claim) AS max_days
FROM claims
GROUP BY Is_Fraud;

--8.Fraud rate by there risk level
SELECT 
    CASE 
        WHEN (Claim_Amount - Approved_Amount) > 200 
             AND Days_Between_Service_and_Claim <= 6 
             AND Number_of_Claims_Per_Provider_Monthly >= 100 
        THEN 'High Risk'
        WHEN (Claim_Amount - Approved_Amount) > 200 
             OR Days_Between_Service_and_Claim <= 6 
             OR Number_of_Claims_Per_Provider_Monthly >= 100 
        THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Label,
    COUNT(*) AS total_claims,
    SUM(Is_Fraud) AS actual_fraud_claims,
    ROUND(100.0 * SUM(Is_Fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM claims
GROUP BY Risk_Label
ORDER BY fraud_rate_pct DESC;


--9.final table for powerbi
CREATE TABLE claims_with_risk AS
SELECT *,
    (Claim_Amount - Approved_Amount) AS Claim_Approved_Gap,
    CASE 
        WHEN (Claim_Amount - Approved_Amount) > 200 
             AND Days_Between_Service_and_Claim <= 6 
             AND Number_of_Claims_Per_Provider_Monthly >= 100 
        THEN 'High Risk'
        WHEN (Claim_Amount - Approved_Amount) > 200 
             OR Days_Between_Service_and_Claim <= 6 
             OR Number_of_Claims_Per_Provider_Monthly >= 100 
        THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Label
FROM claims;

select count(*) from claims_with_risk;