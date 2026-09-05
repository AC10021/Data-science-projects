# EV Purchase Prediction

Binary classification project for Kaggle's Playground Series competition [S6E9: Predicting Electric Vehicle Purchases](https://www.kaggle.com/competitions/playground-series-s6e9). Predicts whether a customer will purchase an electric vehicle based on different features.

## Objective

This project mainly focuses on feature engineering and other advanced techniques:

- Mutual information
- K-Means clustering
- Target encoding
- PCA
- Hyperparameter optimisation
- Pipeline building

## Key results

| Model | Best Feature Set | Holdout AUC |
|---|---|---|
| **LightGBM** | + Cluster | **0.9416** |
| XGBoost | Baseline | 0.9414 |
| Random Forest | + PCA | 0.9391 |
| Decision Tree | Baseline | 0.9384 |

Final model: tuned LightGBM, refit on the full training set for competition submission.

## Analysis 

*Details to be added*

## Requirements

Python, pandas, scikit-learn, category_encoders, LightGBM, XGBoost, matplotlib, seaborn

> **Note:** This notebook runs on the full training set with 5-fold cross-validation across 4 models, an ablation study over multiple feature configurations, and hyperparameter tuning via `RandomizedSearchCV`. Executing the notebook may take significant time (30+ minutes) depending on hardware, particularly the ablation and tuning cells. 

## Files

- `EV_prediction.ipynb` — full analysis notebook
- `submission.csv` — final Kaggle submission

## Notes
The `train.csv` and `test.csv` datasets are not included in this repository, due to Kaggle's competition rules. Dataseets can be found in [Kaggle Playground Series S6E9](https://www.kaggle.com/competitions/playground-series-s6e9) to reproduce this notebook.
