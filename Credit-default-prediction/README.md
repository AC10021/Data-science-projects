---

# Credit-default-prediction
End-to-end credit default prediction pipeline built with SQLite (data cleaning, feature engineering) and Python/scikit-learn (Decision Tree, Random Forest, Logistic Regression, Gradient Boosting). Translates model output into a portfolio Expected Loss estimate and stress-tests it under a simulated economic downturn.

---

## Overview
This project predicts loan default risk using the Kaggle Credit Risk Dataset (32,581 loan applications), split deliberately across two tools to mirror how a real data/risk team works: *SQL (SQLite)* for data preparation, *Python* for modelling. After modelling, expected Loss estimate and stress-testing under a simulated income shock is performed to verify the model.

---

## Key Results

- Gradient Boosting had the best performance on every metric (0.926 accuracy, 0.931 ROC-AUC), while Logistic Regression scored worst across the board — consistent with default risk here being driven by non-linear thresholds.
- A single Decision Tree overfits badly past depth 9, with test accuracy getting worse as the tree grew deeper. Random Forest (depth 8) and Gradient Boosting didn't show that collapse, despite comparable or greater complexity — direct evidence ensembling fixes the problem.
- Several SQL-engineered features proved genuinely useful: `income_to_loan_ratio`, `loan_percent_income`, and `loan_grade_ordinal` all ranked among Gradient Boosting's top predictors. However, `prior_default_flag` wasn't as useful as expected — both correlation and feature importance stayed weak.
- Using Gradient Boosting's predicted probabilities, base-case expected loss came to $8.53M — 13.65% of total exposure ($62.45M).
- A 20% income shock pushed expected loss to $11.12M, a 30.5% increase — disproportionate to the size of the shock, further evidence of the non-linear relationships driving these predictions.

---

## Analysis Covers

`eda.sql`:
- Exploring missing values, duplicated rows and identifying outliers
- Median-imputation for missing values
- Feature engineering:
  - Income to loan ratio
  - Credit maturity relative to adult lifetime
  - Employment stability
  - Age group
  ... and more


 
`Credit_risk_prediction.ipynb`:
- Exploratory data analysis: correlation heatmap, distribution comparisons by default status
- Decision Tree classifier, with a diagnosed overfitting/instability analysis across tree depths
- Random Forest classifier, with feature importance analysis
- Broader model comparison: Logistic Regression and Gradient Boosting, evaluated alongside the tree-based models
- Expected Loss estimation (PD × LGD × EAD) using the best-performing model
- Stress testing under a simulated economic downturn
- Model evaluation via ROC-AUC and Precision-Recall curves


---

## Data Sources

**Credit risk dataset**

The file `credit_risk_dataset.csv` is in this repository. The full source of the credit risk dataset can be found at https://www.kaggle.com/datasets/laotse/credit-risk-dataset/data. 

---

## How to Run
**1. Get the data** 
Download `credit_risk_dataset.csv` from the Kaggle link above and place it in the project root, renamed to `raw_data.csv`.

**2. Set up the Python environment**
```bash
python3 -m venv venv
source venv/bin/activate
pip install pandas numpy matplotlib seaborn scikit-learn jupyter ipykernel
```
**3. Run the SQL stage to produce clean.csv**
Run the `raw_data.csv` to produce `clean.csv`. `clean.csv` is exported via DB Browser for SQLite's GUI (File → Export → Table as CSV, selecting the features table) — see comments in `eda.sql` Section 4 for the exact steps.

**4. Run the modelling notebook**
Open `Credit_risk_prediction.ipynb` and run all cells.

---

## File Structure

```
Credit-default-prediction/
├── credit_risk_dataset.csv                         # Credit risk data
├── EDA                                             # Exploratory data analysis
  ├── eda.sql                                       # SQL version for eda
├── credit_risk_prediction.ipynb                    # Model construction notebook
└── README.md                                       # This file                                   
```

---

## Requirements

- Python 3.9+
- pandas
- numpy
- matplotlib
- scipy
- scikit-learn
- seaborn

> **Note:** Developed on macOS (Apple Silicon). Check your own installed versions with pip show <package> before pinning exact versions in your own environment — package versions may differ across machines, but the code should remain compatible with reasonably recent releases of each library.
> ```bash
> pip install pandas numpy matplotlib seaborn scikit-learn jupyter ipykernel
> ```

---

## Limitations
- LGD and EAD were assumptions as no recovery or collateral data existed in the dataset to estimate loss-given-default more precisely.
- Gradient Boosting doesn't support `class_weight='balanced'`, since the data itself was imbalanced — the confusion matrix showed it misses ~28% of actual defaulters despite high accuracy.
- 20% income shock was not based on any macroeconomic models or real scenarios. A more realistic approximation may require some macroeconomic models to support. 


---

Built by Ambrose Chan 
