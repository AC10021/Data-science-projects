# Housing price prediction 

A machine learning project predicting housing prices, built for Kaggle's *Housing Prices Competition for Kaggle Learn Users*.

---

## Overview

The pipeline covers the full workflow from raw data to a submittable prediction: exploratory data analysis, categorical feature cleaning, correlation-based feature selection, model comparison, overfitting control via leaf-node tuning and cross validation.

Three models, decision tree, random forests and XGBoost, are compared and evaluated by mean absolute error. The best-performing model is then retrained on the full training set and used to generate predictions on the test set.

---

## Key Results

| Model | MAE (validation split) | MAE (5-fold CV mean) |
|---|---|---|
| Decision Tree (untuned) | 26,432 | - |
| Decision Tree (tuned, `max_leaf_nodes=50`) | 24,001 | 25160 |
| **Random Forest** | **17,878** | 19137 |
| XGBoost | 18,302 | 18,972 |

- Random forest has the best single-split MAE; XGBoost edges it out slightly on cross-validation
- Random forest was chosen as the final model
- `OverallQual` is by far the most influential feature, followed by `GrLivArea` and `TotalBsmtSF`

---

## Analysis Covers

`House_price_prediction.ipynb`:

- EDA: missing-value audit, cardinality check, and category-dominance check across all 43 categorical columns
- Feature cleaning: dropped 10 columns that were mostly missing (`PoolQC`, `Alley`, `Fence`, `MiscFeature`) or near-constant (`Street`, `Utilities`, `Condition2`, `RoofMatl`, `Heating`, `CentralAir`)
- Ordinal encoding for quality-scale columns 
- One-hot encoding for other nominal columns
- Correlation-based feature selection, whilst dropping some correlated pairs (`GarageArea`/`GarageCars`, `1stFlrSF`/`TotalBsmtSF`, `TotRmsAbvGrd`/`GrLivArea`)
- Model comparison: decision tree baseline, `max_leaf_nodes` tuning, random forest, XGBoost 
- Final model retrained on the full training set and used to predict on the competition test set

---

## Data Sources

**Ames Housing Dataset**

`train.csv` and `test.csv` from Kaggle's [Housing Prices Competition for Kaggle Learn Users](https://www.kaggle.com/competitions/home-data-for-ml-course/data). Download both files from the competition page. 

`data_description.txt` (also from the competition page) documents every column and category, and was used throughout to determine encoding order.

---

## How to Run

**1. Clone the repository**

```
git clone https://github.com/AC10021/Basic-housing-price-prediction
```

**2. Download the data**

Download `train.csv` and `test.csv` from the [competition data page](https://www.kaggle.com/competitions/home-data-for-ml-course/data).

**3. Install dependencies**

```
pip install pandas scikit-learn seaborn matplotlib xgboost
```

**4. Run the notebook**

Open `House_price_prediction.ipynb` in VS Code or Jupyter and run all cells top to bottom. This regenerates `price_predictions.csv`, the final Kaggle submission file.

---

## File Structure

```
Basic-housing-price-prediction/
├── Data                              
    ├── train.csv                        
    ├── test.csv                       
    ├── data_description.txt           # Description about the data
├── House_price_prediction.ipynb       # Model building 
├── price_predictions.csv              # Final Kaggle submission
└── README.md                          # This file
```

---

## Requirements

- Python 3.9+
- pandas
- scikit-learn
- seaborn
- matplotlib
- xgboost

> **Note:** Dependencies listed are based on a macOS environment (pandas 3.0.3, scikit-learn 1.9.0). Package versions may differ on Windows or Linux but the code should remain compatible.

---

Built by Ambrose Chan
