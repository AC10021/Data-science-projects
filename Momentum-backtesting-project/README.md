---

# Cross-Sectional Momentum Strategy — S&P 500

A systematic backtest of a 12-1 month cross-sectional momentum strategy applied to S&P 500 constituent stocks from January 2015 to June 2026.


---

## Overview

Each month, all S&P 500 constituents are ranked by their 12-1 month return. The top 20 stocks are selected and held in equal weights until the next monthly rebalance. The most recent month is excluded from the signal to avoid short-term reversal effects, following the methodology of Jegadeesh and Titman (1993).

Historical constituent data is used at each rebalance date to ensure only stocks actually in the index at that time are eligible for selection, mitigating survivorship bias.

---

## Key Results

<div align="center">
  
| Metric | Strategy | S&P 500 |
|---|---|---|
| CAGR | 20.3% | ~13-14% |
| Sharpe Ratio | 0.80 | ~0.5-0.7 |
| Max Drawdown | -22.7% | ~-34% |

</div>

**Market Risk Metrics:**

<div align="center">
  
| Metric	| 95%	| 99% |
|---|---|---|
| Historical VaR | 6.64%	| 14.43% |
| Parametric VaR	| 8.26%	| 12.40% |
| Historical CVaR	| 11.19%	| 15.48% |
| Parametric CVaR	| 10.80%	| 14.46% |

</div>

**Signal Comparison:**

<div align="center">
  
| Signal	| CAGR	| Sharpe	| Max Drawdown |
| --- | --- | --- | --- |
| Momentum	| 20.38%	| 0.80	| -22.72% |
| Mean Reversion |	18.40% |	0.60 |	-40.70% |
| XGBoost	| 29.38%	| 0.94	| -29.76% |

</div>

- Strategy outperforms the S&P 500 across all three metrics
- Performance holds across all 16 parameter combinations tested in sensitivity analysis, with Sharpe ratios ranging from 0.73 to 1.00
- Strategy remains profitable after transaction costs — CAGR of 18.2% at 50 basis points per trade
- Volatility filter worsened performance, consistent with high volatility periods still generating positive momentum returns
- Strategy beta of -0.09 indicates near-zero correlation with S&P 500
- Parametric VaR underestimates tail risk at 99% confidence relative to historical — consistent with fat tail behaviour in real return distributions

---

## Analysis Covers

`Momentum_backtesting.ipynb`:
- Strategy returns vs S&P 500 benchmark
- Risk-adjusted performance: Sharpe ratio, CAGR, maximum drawdown
- Turnover analysis and transaction cost sensitivity
- Regime analysis: performance broken down by bull, bear and high volatility periods
- Volatility filter: effect of going to cash during high volatility months
- Sensitivity analysis: 16 combinations of lookback period and portfolio size
- Market risk metrics: Value at Risk (VaR) and Expected Shortfall (CVaR) at 95% and 99% confidence levels
- Stress testing: estimated strategy performance during known market crash scenarios within the sample period

`signal_comparison.ipynb`:
- Momentum vs mean reversion vs XGBoost signal comparison
- Three-way equity curve and performance table
- XGBoost trained with rolling expanding window — no lookahead bias

---

## Data Sources

**Price Data**

Downloaded automatically from Yahoo Finance via the yfinance library on first run. No manual download required.

**S&P 500 Historical Constituent Data**

The file `S&P 500 Historical Components & Changes (Updated).csv` is included in this repository. It tracks historical S&P 500 index additions and deletions, enabling the backtest to use only stocks that were actually in the index at each rebalance date. The original source is [https://github.com/fja05680/sp500](https://github.com/fja05680/sp500) — download the latest version from there if you need more recent constituent changes.

**S&P 500 Company Info**

The file `sp500.csv` provides current sector classifications used as a feature in the XGBoost model.

---

## How to Run

**1. Clone the repository**
```bash
git clone https://github.com/AC10021/momentum-backtesting-project
```

**2. Download the constituent data**

Download `S&P 500 Historical Components & Changes (Updated).csv` from the link above and place it in the project folder.

**3. Install dependencies**
```bash
pip install yfinance pandas numpy matplotlib scipy
```

**4. Run the notebook**

Open `Momentum_backtesting.ipynb`, then `signal_comparison.ipynb` in VS Code or Jupyter and run all cells. Price data downloads automatically from Yahoo Finance on first run.

Note: XGBoost training in signal_comparison.ipynb takes several minutes.

---

## File Structure

```
momentum-strategy/
├── Data
    ├── S&P 500 Historical Components & Changes (Updated).csv   # Historical constituent data
    ├── sp500.csv                                               # S&P 500 company info and sectors
├── Momentum_backtesting.ipynb                                  # Main momentum backtest
├── signal_comparison.ipynb                                     # Signal comparison notebook
└── README.md                                                   # This file                                   
```

---

## Requirements

- Python 3.9+
- yfinance
- pandas
- numpy
- matplotlib
- scipy
- scikit-learn
- xgboost

> **Note:** Dependencies listed are based on a macOS (Apple Silicon) environment. Package versions may differ on Windows or Linux but the code should remain compatible. If you encounter issues, install the specific versions used in development:
> ```bash
> pip install yfinance==1.5.1 pandas==3.0.3 numpy==2.5.1 matplotlib scipy scikit-learn xgboost
> ```

---

## Limitations

- Price data is downloaded using the most recent constituent list, meaning delisted companies may not appear. This introduces a degree of survivorship bias the historical filtering alone does not fully resolve
- Results are estimated net of transaction costs but slippage and market impact are not modelled
- The sample period is predominantly bullish, limiting bear market evaluation
- Month-end pricing means intra-month drawdowns are not captured
- XGBoost uses only three features — a richer feature set would likely improve predictions

---

Built by Ambrose Chan 
