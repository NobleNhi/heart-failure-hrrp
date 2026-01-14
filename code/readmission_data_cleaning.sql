
-- Check on data
SELECT * FROM hrrp_raw hr 
LIMIT 10;

-- Clean data and save as a new table
CREATE TABLE cleaned_hrrp AS 
SELECT 
	"Facility Name", "Facility ID", state, "Measure Name",
    "Number of Discharges", "Excess Readmission Ratio",
    "Predicted Readmission Rate", "Expected Readmission Rate"
FROM hrrp_raw 
WHERE "Excess Readmission Ratio" IS NOT NULL
	AND "Excess Readmission Ratio" <> 'N/A'
	AND "Measure Name" LIKE 'READM-30-HF%'  -- heart failure only
  	AND "Number of Discharges" IS NOT NULL
	AND "Number of Discharges" <> 'N/A';    

-- Check the first few rows to make sure the data is correct
SELECT *
FROM cleaned_hrrp
LIMIT 10;

-- Confirm there is no NULL or N/A values
SELECT *
FROM cleaned_hrrp
WHERE "Excess Readmission Ratio" = 'N/A'
	OR "Number of Discharges" = 'N/A'; -- Return 0 rows
	
-- Convert Number of Discharges to Integer
ALTER TABLE cleaned_hrrp 
ALTER COLUMN "Number of Discharges" 
TYPE INTEGER 
USING ("Number of Discharges")::INTEGER;

-- Convert Excess Readmission Ratio to Decimal
ALTER TABLE cleaned_hrrp 
ALTER COLUMN "Excess Readmission Ratio" 
TYPE DECIMAL(10,4)
USING ("Excess Readmission Ratio"):: DECIMAL(10,4);

-- Convert Predicted Readmission Rate to Decimal
ALTER TABLE cleaned_hrrp 
ALTER COLUMN "Predicted Readmission Rate" 
TYPE DECIMAL(10,4)
USING ("Predicted Readmission Rate")::DECIMAL(10,4);

-- Convert Expected Readmission Rate to Decimal
ALTER TABLE cleaned_hrrp 
ALTER COLUMN "Expected Readmission Rate" 
TYPE DECIMAL(10,4)
USING ("Expected Readmission Rate")::DECIMAL(10,4);

-- SUMMARY STATISTICS (for report)
-- Count number of hospitals
select count("Facility ID")
from cleaned_hrrp ch 
-- 2342 hospitals

-- Distribution of Number of Discharges
SELECT 	
    MIN ("Number of Discharges") as min_discharges, 
    MAX ("Number of Discharges") as max_discharges,  
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "Number of Discharges") as median_discharges,
    AVG("Number of Discharges") as avg_discharges
FROM cleaned_hrrp 
-- Results: min=30, median=276.5, mean=373.74, max=3490

-- Summary stats by state
SELECT 
	state,
    COUNT(*) as hospital_count,
    AVG("Excess Readmission Ratio") as avg_excess_ratio,
    AVG("Number of Discharges") as avg_discharges
FROM cleaned_hrrp 
GROUP BY state 
ORDER BY avg_excess_ratio DESC;


  





