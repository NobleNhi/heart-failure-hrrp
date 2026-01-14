# Heart Failure Readmissions under HRRP

**An end-to-end analytics project analyzing 2,342 U.S. hospitals' 30-day heart failure readmission performance using SQL and R.**

This project builds an end-to-end healthcare analytics pipeline in SQL and R to study U.S. hospital performance on 30-day excess readmissions for heart failure under Medicare’s Hospital Readmissions Reduction Program (HRRP). The focus is on demonstrating applied data cleaning, exploratory data analysis, and regression modeling with attention to key econometric assumptions.

Using CMS hospital-level data for the READM-30-HF measure, the analysis examines how hospital volume and geography relate to excess readmission ratios and illustrates how to diagnose and address heteroskedasticity in linear models.

## Research questions

The analysis is organized around three questions:

- How does the excess readmission ratio for heart failure (READM-30-HF) vary across U.S. states?  
- Are higher-volume hospitals, measured by the number of heart failure discharges, associated with better or worse excess readmission ratios after accounting for state differences?  
- How much additional variation in excess readmission ratios is explained by state-level differences, beyond what can be captured by hospital volume alone?

The analysis measures hospital volume using the number of heart failure discharges reported in the HRRP data. This variable is interpreted as a measure of how many heart failure patients a hospital treats, and thus as a simple indicator of hospital volume for this condition.

## Repository guide

- **Data**
  - `data/FY_2025_Hospital_Readmissions_Reduction_Program_Hospital.csv` – Raw HRRP file from CMS.
  - `data/cleaned_hrrp.csv` – Cleaned hospital-level dataset for READM-30-HF.

- **Code**
  - `code/readmission_data_cleaning.sql` – PostgreSQL cleaning script.
  - `code/hrrp_readmissions.Rmd` – Full R analysis (EDA, models, diagnostics).
  - `code/hrrp_readmissions.md` – Rendered GitHub document with code, output, and plots.

## Data and pipeline

The analysis uses public data from the Centers for Medicare & Medicaid Services (CMS) Hospital Readmissions Reduction Program (HRRP), focusing on the heart failure measure READM-30-HF. The unit of analysis is the individual hospital’s risk-standardized 30-day excess readmission performance for heart failure.

The raw HRRP extract is stored under `data/`, and the cleaned hospital-level analysis dataset is saved as `data/cleaned_hrrp.csv`.

Key variables used in the analysis include:

- Facility ID and Facility Name (hospital identifiers).  
- State (two-letter postal code).  
- Number of Discharges and Number of Readmissions for heart failure. 
- Predicted and Expected Readmission Rates.  
- Excess Readmission Ratio (risk-standardized; values above 1 indicate higher-than-expected readmissions).

## Pipeline and code structure

The project is implemented in two main stages:

### 1. Data cleaning in SQL (PostgreSQL)

- Import the raw CMS CSV into PostgreSQL with safe types.  
- Filter to the READM-30-HF heart failure measure.  
- Remove rows with missing or non-numeric values (ex: N/A) in key variables.  
- Cast numeric fields to appropriate numeric types.  
- Export the cleaned hospital-level table as `cleaned_hrrp.csv`.

All SQL used to clean and filter the data is in `code/readmission_data_cleaning.sql`.

### 2. Exploratory analysis and modeling in R

- Load the cleaned data and perform basic structure checks.  
- Explore distributions of excess readmission ratios and hospital volume (raw and log-transformed).  
- Visualize geographic variation in excess readmission ratios by state and by census region.  
- Fit a sequence of linear models:
  - log(Number of Discharges) only,  
  - state fixed effects only, and  
  - log(Number of Discharges) plus state fixed effects.  
- Compare models using \(R^2\) and a nested F-test, and assess heteroskedasticity using the Breusch–Pagan test and heteroskedasticity-consistent (HC1) standard errors.
  
All modeling and plots are implemented in `code/hrrp_readmissions.Rmd`, with the rendered GitHub-friendly version in `code/hrrp_readmissions.md`.

## Main findings (brief)

- Hospital volume, measured as log(Number of Discharges) for heart failure, has a small but statistically significant negative association with excess readmission ratios (β = -0.014, p < 0.001). Moving from the 25th to 75th percentile in volume is associated with a 0.017-point decrease in excess readmission ratio. However, volume alone explains less than 2% of variation, while state fixed effects explain approximately 12%. Higher-volume hospitals tend to have slightly lower excess readmission ratios on average, holding state fixed.  
- State fixed effects explain a meaningful portion of cross-hospital variation in excess readmission ratios, suggesting that geography and state-level factors matter alongside individual hospital characteristics.  
- Diagnostic tests detect heteroskedasticity in the main regression, so robust HC1 standard errors are used; the key coefficients remain statistically significant under this more conservative inference.

## How to run the analysis

To reproduce the R analysis:

1. Clone this repository.  
2. Open the project folder in RStudio.  
3. Open `code/hrrp_readmissions.Rmd`.  
4. Knit the document (the Rmd is configured with `output: github_document` and reads the cleaned dataset from `../data/cleaned_hrrp.csv`).

Required R packages include:

- `ggplot2`  
- `dplyr`  
- `sandwich`  
- `lmtest`  

The SQL cleaning is written for PostgreSQL and can be run from any SQL client connected to a local PostgreSQL instance.
