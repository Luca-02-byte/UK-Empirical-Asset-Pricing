# Empirical Asset Pricing: Time-Series and Cross-Sectional Analysis on the UK Stock Market


## Overview
Tests the CAPM, the Fama and French three-factor model and the Carhart four-factor model on ten UK size sorted portfolios (monthly data, 1980–2010, 363 observations).

## Methods
- Descriptive statistics and a 2%/98% winsorization robustness check
- Time-series OLS regressions with HC1 robust standard errors
- GRS test on joint pricing errors (alphas)
- Second-stage cross-sectional regressions (two-factor models and empirical security market line)

## Main findings
- Average excess returns decrease with firm size (size effect); small caps have the highest alphas.
- Carhart 4F is the only model for which the GRS test does not reject at the 5% level (p = 0.055, a marginal result); CAPM (p = 0.032) and FF3 (p = 0.024) are rejected.
- In the cross-section the market price of risk is negative (low-beta anomaly), and SMB, HML and UMD premia are not significant when paired individually with the market factor.

## Repository content
- [`report.pdf`](./Empirical_asset_pricing.pdf): full report
- [`EAP.ipynb`](./EAP.ipynb): Python analysis used for producing the graphs
- [`EAP.do`](./EAP_.do): Stata analysis used for running the analysis

## Data
The datasets (`First_Assignment_dataset.xlsx`) are provided by the course and are not included in this repository.
