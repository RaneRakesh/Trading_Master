# Trading Master — AI-Assisted Trading & Investment Decision-Support System

A full-stack, AI-assisted decision-support platform built strictly according to the 37-page system architecture blueprint.

## 🚀 Architecture Overview

```
Market Data (NSE/BSE/Yahoo)
    │
    ▼
FastAPI Backend (Port 8000)
    ├── Feature Engine (RSI, MACD, EMA 9/20/50/200, SMA 20/50/200, ATR, VWAP, Bollinger Bands)
    ├── Multi-Mode AI Models:
    │   ├── Intraday Model (5m/15m timeframe, 30–120 min horizon)
    │   ├── Swing Model (1h/Daily timeframe, 2–20 days / 5-day horizon)
    │   └── Investment Model (Fundamental Scorecard 0–100, Valuation, Growth, Risk)
    ├── Signal & Reasoning Engine ("Why BUY/SELL?", Risk Warnings)
    ├── Risk Engine & Position Sizer (Capital & Stop-loss based share calculation)
    └── Walk-Forward Backtesting Simulator
    │
    ▼ JSON REST API
Flutter Client UI (Web / Mobile / Desktop)
    ├── Dashboard with Live Market Regime (NIFTY 50, BANKNIFTY)
    ├── Mode Switcher Tabs (Intraday / Swing / Investment)
    ├── Interactive Candlestick & Volume Chart with Timeframes (1D, 5D, 1M, 6M, 1Y)
    ├── Prediction Card with Confidence Meter Gauge & Transparent Explanations
    ├── Position Sizing & Capital Protection Dialog
    ├── Investment Fundamental Scorecard (Financial Multiples: P/E, P/B, ROE, D/E)
    └── Historical Walk-Forward Strategy Backtest Report
```

## 🛠️ Technology Stack
- **Backend**: Python 3.10+, FastAPI, Pandas, NumPy, Scikit-learn, YFinance, Pytest, Uvicorn.
- **Frontend**: Flutter 3.44+ (Dart 3.12+), Provider State Management, Custom Canvas Candlestick & Line Chart, Modern Dark Financial Terminal Theme.

## 🏁 Quick Start

### 1. Unified Launch Script (`run.sh`):
The included [`run.sh`](file:///home/credentek/dartpedia/Trading_Master/run.sh) automatically manages environment tools (Java 17+ JBR, Android SDK, ADB reverse tunneling, Python dependencies, Flutter packages), launches the FastAPI backend, and runs the client:

```bash
# Auto-detect (launches on connected mobile device if present, else web server)
./run.sh

# Target connected Android mobile device explicitly
./run.sh mobile

# Target specific Android device ID
./run.sh -d R9ZR30HWSBN

# Target Web browser (accessible on network at http://localhost:3000)
./run.sh web

# Target Google Chrome desktop app
./run.sh chrome
```

### 2. Or Run Backend Independently:
```bash
cd backend
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
- API Docs: `http://localhost:8000/docs`
- Health Check: `http://localhost:8000/health`

### 3. Run Flutter Frontend Independently:
```bash
cd frontend
flutter run -d <device_id> # e.g. chrome / web-server / android device
```

## 🧪 Verification & Tests
- **Backend Tests**:
  ```bash
  python3 -m pytest backend/tests/test_backend.py -v
  ```
- **Flutter Analysis & Tests**:
  ```bash
  cd frontend
  flutter analyze
  flutter test
  ```
