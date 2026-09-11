create database AI_Finance ;
use AI_Finance ;
SELECT * FROM customer;
SELECT * FROM loan;
SELECT * FROM risk;
SELECT * FROM decision;

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('customer', 'loan', 'risk', 'decision')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

ALTER TABLE loan
RENAME COLUMN tenure TO Duration_months;
ALTER TABLE risk
RENAME COLUMN dti TO debt_ratio;


-- Loan Demand
SELECT l.type,
       COUNT(*) AS applications
FROM loan l
GROUP BY l.type
ORDER BY applications DESC;

-- Approval by Loan Type
SELECT l.type,
       COUNT(*) AS applications,
       SUM(d.approved) AS approved,
       SUM(CASE WHEN d.status = 'Rejected' THEN 1 ELSE 0 END) AS rejected
FROM loan l
JOIN decision d ON l.app_id = d.app_id
GROUP BY l.type;

-- Risk Analysis
SELECT r.band,
       COUNT(*) AS applications,
       SUM(d.approved) AS approved,
       SUM(CASE WHEN d.status = 'Rejected' THEN 1 ELSE 0 END) AS rejected
FROM risk r
JOIN decision d ON r.app_id = d.app_id
GROUP BY r.band;

-- Credit Score Impact
SELECT
    CASE
        WHEN c.score >= 750 THEN 'High'
        WHEN c.score >= 650 THEN 'Medium'
        ELSE 'Low'
    END AS score_group,
    COUNT(*) AS applications,
    SUM(d.approved) AS approved
FROM customer c
JOIN loan l ON c.id = l.id
JOIN decision d ON l.app_id = d.app_id
GROUP BY score_group;

-- Income & Approval
SELECT
    CASE
        WHEN c.income < 30000 THEN 'Low'
        WHEN c.income < 75000 THEN 'Medium'
        ELSE 'High'
    END AS income_group,
    COUNT(*) AS applications,
    SUM(d.approved) AS approved
FROM customer c
JOIN loan l ON c.id = l.id
JOIN decision d ON l.app_id = d.app_id
GROUP BY income_group;

--  Market Opportunity ⭐
SELECT c.city,
       COUNT(*) AS applications,
       SUM(d.approved) AS approved,
       ROUND(100 * SUM(d.approved) / COUNT(*), 2) AS approval_rate
FROM customer c
JOIN loan l ON c.id = l.id
JOIN decision d ON l.app_id = d.app_id
GROUP BY c.city
HAVING COUNT(*) >= 100
ORDER BY applications DESC;