# 🐋 Crypto Whale Tracker — Project Architecture & AI Coding Prompt

> **Stack Rating: 9.5/10** | Production-Ready | Scalable | Monorepo  
> Last updated: May 2026

---

## 📐 Final Architecture

```
┌──────────────────────────────────────────────────────┐
│                    DATA LAYER                         │
│  Python Asyncio + ccxt.pro (WebSocket exchanges)      │
│  web3.py  → ETH / BSC / Arbitrum / Base (EVM)         │
│  solana-py → Solana on-chain                          │
│  Go service (optional - high-frequency WS)            │
│  → Redis Streams (primary queue)                      │
│  → RabbitMQ (optional - complex routing later)        │
└─────────────────────┬────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────────┐
│              CORE ENGINE (Python workers)             │
│  ├── Whale Detector Service                           │
│  ├── On-chain Monitor (EVM + Solana)                  │
│  ├── TA Engine (pandas + ta-lib)                      │
│  ├── ML Predictor                                     │
│  │     scikit-learn → LightGBM → LSTM (3 tiers)       │
│  └── Signal Combiner + Risk Manager                   │
└─────────────────────┬────────────────────────────────┘
                      ↓ (Redis pub/sub)
┌──────────────────────────────────────────────────────┐
│            ALERT & API LAYER                          │
│  FastAPI                                              │
│  ├── REST API /api/v1/ + WebSocket Server             │
│  └── Rate Limiting (slowapi) + Auth (JWT)             │
│  Alert Workers (separate process)                     │
│  ├── Telegram Bot Worker                              │
│  └── Discord Webhook Worker                           │
└─────────────────────┬────────────────────────────────┘
                      ↓
┌──────────────────────────────────────────────────────┐
│        FRONTEND (Next.js 16 + TS + Tailwind)          │
│  ├── Live Whale Feed (WebSocket)                      │
│  ├── Signal Dashboard                                 │
│  ├── Backtesting UI                                   │
│  └── User Alert Settings                              │
└──────────────────────────────────────────────────────┘

DATABASE
├── Supabase (PostgreSQL)
│   ├── TimescaleDB extension → OHLCV, time-series
│   ├── Auth + user settings + alert config
│   └── Historical signals + trade logs
└── Redis
    ├── Streams  → message queue
    ├── Pub/Sub  → real-time broadcast
    └── Cache + rate limiting

OBSERVABILITY (9.5/10 additions)
├── Prometheus     → metrics collection
├── Grafana        → dashboards & alerting
├── Sentry         → error tracking (Python + Next.js)
└── GitHub Actions → CI/CD pipeline
```

---

## 📁 Complete Folder Structure

```
crypto-whale-tracker/                   # Monorepo root
│
├── 📄 docker-compose.yml               # Full stack (prod-like)
├── 📄 docker-compose.dev.yml           # Dev override (hot reload)
├── 📄 .env.example                     # All env vars documented
├── 📄 .gitignore
├── 📄 README.md
├── 📄 ARCHITECTURE.md                  # This file
│
├── 📁 data-layer/                      # Raw data ingestion
│   ├── 📁 python/
│   │   ├── 📁 collectors/
│   │   │   ├── exchange_ws.py          # ccxt.pro WebSocket streams
│   │   │   ├── onchain_evm.py          # web3.py ETH/BSC/Arbitrum/Base
│   │   │   └── onchain_solana.py       # solana-py Solana chain
│   │   ├── 📁 publishers/
│   │   │   └── redis_stream.py         # Push raw data → Redis Streams
│   │   ├── 📁 schemas/
│   │   │   └── raw_events.py           # Pydantic models for raw data
│   │   ├── config.py
│   │   ├── main.py                     # Entry point
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   │
│   └── 📁 go/                          # Optional high-freq WS
│       ├── 📁 cmd/
│       │   └── ingester/
│       │       └── main.go
│       ├── 📁 internal/
│       │   ├── ws/
│       │   └── publisher/
│       ├── go.mod
│       ├── go.sum
│       └── Dockerfile
│
├── 📁 core-engine/                     # Brain of the system
│   ├── 📁 workers/
│   │   │
│   │   ├── 📁 whale_detector/
│   │   │   ├── __init__.py
│   │   │   ├── detector.py             # Main detection logic
│   │   │   ├── filters.py              # Size/volume/OI filters
│   │   │   └── tests/
│   │   │       └── test_detector.py
│   │   │
│   │   ├── 📁 onchain_monitor/
│   │   │   ├── __init__.py
│   │   │   ├── evm_monitor.py          # ETH/BSC/Arbitrum whale wallets
│   │   │   ├── solana_monitor.py       # Solana whale wallets
│   │   │   └── tests/
│   │   │       └── test_monitors.py
│   │   │
│   │   ├── 📁 ta_engine/
│   │   │   ├── __init__.py
│   │   │   ├── indicators.py           # RSI, MACD, BB, EMA, etc.
│   │   │   ├── patterns.py             # Candlestick patterns
│   │   │   └── tests/
│   │   │       └── test_indicators.py
│   │   │
│   │   ├── 📁 ml_predictor/
│   │   │   ├── 📁 baseline/            # Tier 1: scikit-learn
│   │   │   │   ├── model.py
│   │   │   │   └── features.py
│   │   │   ├── 📁 boosting/            # Tier 2: LightGBM
│   │   │   │   ├── model.py
│   │   │   │   └── features.py
│   │   │   ├── 📁 deep/                # Tier 3: LSTM
│   │   │   │   ├── model.py
│   │   │   │   └── trainer.py
│   │   │   ├── 📁 models/              # Saved model artifacts (.pkl, .pt)
│   │   │   └── tests/
│   │   │       └── test_predictors.py
│   │   │
│   │   └── 📁 signal_combiner/
│   │       ├── __init__.py
│   │       ├── combiner.py             # Merge signals from all workers
│   │       ├── risk_manager.py         # Position sizing, stop-loss logic
│   │       └── tests/
│   │           └── test_combiner.py
│   │
│   ├── 📁 shared/
│   │   ├── redis_client.py             # Redis connection + helpers
│   │   ├── models.py                   # Shared Pydantic models
│   │   ├── constants.py                # Thresholds, coin lists, etc.
│   │   └── logger.py                   # Structured logging
│   │
│   ├── main.py                         # Worker orchestrator
│   ├── requirements.txt
│   ├── pytest.ini
│   └── Dockerfile
│
├── 📁 api-layer/                       # FastAPI + Alert Workers
│   ├── 📁 app/
│   │   ├── main.py                     # FastAPI app entry point
│   │   ├── 📁 routers/
│   │   │   ├── __init__.py
│   │   │   ├── signals.py              # GET /api/v1/signals
│   │   │   ├── whales.py               # GET /api/v1/whales
│   │   │   ├── backtesting.py          # POST /api/v1/backtest
│   │   │   └── users.py                # GET/PUT /api/v1/users/me
│   │   ├── 📁 websocket/
│   │   │   ├── manager.py              # WS connection manager
│   │   │   └── handlers.py             # WS event handlers
│   │   ├── 📁 middleware/
│   │   │   ├── auth.py                 # JWT verify middleware
│   │   │   └── rate_limit.py           # slowapi rate limiter
│   │   ├── 📁 schemas/
│   │   │   ├── signal.py               # Request/Response schemas
│   │   │   ├── whale.py
│   │   │   └── user.py
│   │   └── dependencies.py             # DI: DB, Redis, Auth
│   │
│   ├── 📁 alert-workers/
│   │   ├── base_worker.py              # Abstract worker class
│   │   ├── telegram_worker.py          # python-telegram-bot consumer
│   │   ├── discord_worker.py           # Discord webhook consumer
│   │   └── tests/
│   │       └── test_workers.py
│   │
│   ├── requirements.txt
│   ├── pytest.ini
│   └── Dockerfile
│
├── 📁 frontend/                        # Next.js 16 App Router
│   ├── 📁 src/
│   │   ├── 📁 app/                     # App Router pages
│   │   │   ├── layout.tsx              # Root layout
│   │   │   ├── page.tsx                # Landing / redirect
│   │   │   ├── 📁 (auth)/
│   │   │   │   ├── login/
│   │   │   │   │   └── page.tsx
│   │   │   │   └── register/
│   │   │   │       └── page.tsx
│   │   │   ├── 📁 dashboard/
│   │   │   │   └── page.tsx            # Main dashboard
│   │   │   ├── 📁 whales/
│   │   │   │   └── page.tsx            # Live whale feed
│   │   │   ├── 📁 signals/
│   │   │   │   └── page.tsx            # Signal dashboard
│   │   │   ├── 📁 backtest/
│   │   │   │   └── page.tsx            # Backtesting UI
│   │   │   └── 📁 settings/
│   │   │       └── page.tsx            # Alert settings
│   │   │
│   │   ├── 📁 components/
│   │   │   ├── 📁 ui/                  # shadcn/ui base components
│   │   │   ├── 📁 charts/
│   │   │   │   ├── CandlestickChart.tsx
│   │   │   │   ├── SignalChart.tsx
│   │   │   │   └── VolumeChart.tsx
│   │   │   ├── 📁 whale-feed/
│   │   │   │   ├── WhaleFeed.tsx       # Real-time feed container
│   │   │   │   ├── WhaleCard.tsx       # Single whale event card
│   │   │   │   └── WhaleFilter.tsx     # Filter by coin/size/chain
│   │   │   ├── 📁 signal-card/
│   │   │   │   ├── SignalCard.tsx
│   │   │   │   └── SignalBadge.tsx
│   │   │   └── 📁 layout/
│   │   │       ├── Sidebar.tsx
│   │   │       ├── Header.tsx
│   │   │       └── ThemeProvider.tsx
│   │   │
│   │   ├── 📁 hooks/
│   │   │   ├── useWebSocket.ts         # WS connection hook
│   │   │   ├── useSignals.ts           # Signal data hook
│   │   │   ├── useWhales.ts            # Whale feed hook
│   │   │   └── useBacktest.ts          # Backtesting hook
│   │   │
│   │   ├── 📁 lib/
│   │   │   ├── api.ts                  # API client (fetch wrapper)
│   │   │   ├── supabase.ts             # Supabase client
│   │   │   ├── websocket.ts            # WS client singleton
│   │   │   └── utils.ts
│   │   │
│   │   └── 📁 types/
│   │       ├── signal.ts
│   │       ├── whale.ts
│   │       └── index.ts
│   │
│   ├── 📁 public/
│   ├── 📄 package.json
│   ├── 📄 tailwind.config.ts
│   ├── 📄 next.config.ts
│   ├── 📄 tsconfig.json
│   ├── 📄 vitest.config.ts             # Testing config
│   └── 📄 Dockerfile
│
├── 📁 database/
│   ├── 📁 migrations/
│   │   ├── 001_enable_timescaledb.sql
│   │   ├── 002_ohlcv_data.sql          # Hypertable for OHLCV
│   │   ├── 003_whale_events.sql        # Hypertable for whale events
│   │   ├── 004_signals.sql             # Signals + predictions
│   │   ├── 005_backtests.sql           # Backtest runs + results
│   │   └── 006_user_settings.sql       # Alert configs
│   └── 📁 seeds/
│       └── test_data.sql
│
├── 📁 monitoring/                      # 9.5/10 additions
│   ├── 📁 prometheus/
│   │   └── prometheus.yml              # Scrape configs
│   ├── 📁 grafana/
│   │   ├── 📁 dashboards/
│   │   │   ├── whale_tracker.json      # Main trading dashboard
│   │   │   ├── system_health.json      # Worker health
│   │   │   └── api_metrics.json        # API latency/throughput
│   │   └── datasources.yml
│   └── 📁 sentry/
│       └── sentry.properties
│
└── 📁 .github/
    └── 📁 workflows/
        ├── ci.yml                      # Run tests on PR
        └── deploy.yml                  # Deploy on merge to main
```

---

## 🛠️ Tech Stack Summary

| Layer | Technology | Version | Role |
|---|---|---|---|
| Data Ingestion | Python Asyncio + ccxt.pro | latest | Exchange WebSocket streams |
| On-chain EVM | web3.py | ^7.x | ETH/BSC/Arbitrum/Base |
| On-chain Solana | solana-py | ^0.34 | Solana whale tracking |
| High-freq WS | Go (optional) | 1.22+ | Sub-millisecond ingestion |
| Message Queue | Redis Streams | 7.x | Primary queue (simple) |
| Message Queue | RabbitMQ (optional) | 3.x | Complex routing (later) |
| Core Engine | Python | 3.12+ | Workers + ML |
| ML Tier 1 | scikit-learn | ^1.4 | Baseline models |
| ML Tier 2 | LightGBM | ^4.x | Production-grade boosting |
| ML Tier 3 | PyTorch LSTM | ^2.x | Deep learning predictor |
| TA Library | ta-lib + pandas | latest | Technical indicators |
| API | FastAPI | ^0.111 | REST + WebSocket |
| Auth | JWT (python-jose) | ^3.x | Token-based auth |
| Rate Limiting | slowapi | ^0.1 | API rate limiting |
| Alert Bot | python-telegram-bot | ^21.x | Telegram alerts |
| Alert Bot | httpx | ^0.27 | Discord webhooks |
| Frontend | Next.js 16 | 16.2.6 | App Router + SSR |
| UI Framework | TailwindCSS | ^3.x | Styling |
| UI Components | shadcn/ui | latest | Component library |
| Charts | TradingView Lightweight Charts | ^4.x | Candlestick/signals |
| State Management | Zustand | ^4.x | Client state |
| Database | Supabase (PostgreSQL) | latest | Primary DB + Auth |
| Time-series DB | TimescaleDB | ^2.x | OHLCV + whale events |
| Cache/Queue | Redis | 7.x | Pub/sub + cache |
| Error Tracking | Sentry | latest | Python + Next.js |
| Metrics | Prometheus + Grafana | latest | Observability |
| CI/CD | GitHub Actions | - | Automated pipeline |
| Container | Docker + Docker Compose | latest | Local + production |

---

## 🗄️ Key Database Tables (TimescaleDB)

```sql
-- Hypertables (time-partitioned)
ohlcv_data          (time, symbol, exchange, open, high, low, close, volume)
whale_events        (time, tx_hash, chain, wallet, symbol, side, usd_value, exchange)
signals             (time, symbol, signal_type, confidence, source, metadata)

-- Regular tables
users               (id, email, tier, created_at)
alert_configs       (id, user_id, coin, min_usd, channels, filters)
backtest_runs       (id, user_id, strategy, params, start_date, end_date)
backtest_results    (id, run_id, pnl, sharpe, max_drawdown, trades)
```

---

## 🔑 Environment Variables (.env.example)

```bash
# === EXCHANGES ===
BINANCE_API_KEY=
BINANCE_API_SECRET=
BYBIT_API_KEY=
BYBIT_API_SECRET=

# === ON-CHAIN ===
ETH_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
BSC_RPC_URL=https://bsc-dataseed.binance.org
ARBITRUM_RPC_URL=https://arb1.arbitrum.io/rpc
BASE_RPC_URL=https://mainnet.base.org
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com

# === REDIS ===
REDIS_URL=redis://localhost:6379

# === DATABASE ===
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_KEY=
DATABASE_URL=postgresql://user:pass@localhost:5432/whale_tracker

# === API ===
JWT_SECRET=
JWT_EXPIRE_MINUTES=1440
API_HOST=0.0.0.0
API_PORT=8000

# === ALERTS ===
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
DISCORD_WEBHOOK_URL=

# === MONITORING ===
SENTRY_DSN_PYTHON=
SENTRY_DSN_NEXTJS=
PROMETHEUS_PORT=9090

# === WHALE THRESHOLDS ===
WHALE_MIN_USD=100000       # $100k minimum trade size
WHALE_OI_CHANGE_PCT=5      # 5% OI change triggers alert
WHALE_FUNDING_THRESHOLD=0.1 # 0.1% funding rate spike
```

---

## 📋 AI Coding Prompt

> **Sao chép toàn bộ phần dưới đây và dán vào AI coding assistant**

---

```
You are an expert senior full-stack engineer building a production-grade
Crypto Whale Tracker & Trading Signal System. Your code must be
clean, typed, well-commented, and production-ready.

=== PROJECT OVERVIEW ===
A real-time crypto trading tool that:
1. Tracks whale movements on CEX (Binance, Bybit) and on-chain (ETH, BSC, Solana)
2. Detects large trades, OI changes, funding rate spikes as "whale signals"
3. Runs TA indicators + ML models to generate trading signals
4. Alerts users via Telegram, Discord, and a real-time web dashboard
5. Provides backtesting UI to validate strategies

=== TECH STACK ===
- Data Layer: Python 3.12, asyncio, ccxt.pro, web3.py, solana-py, Redis Streams
- Core Engine: Python workers, pandas, ta-lib, scikit-learn, LightGBM, PyTorch LSTM
- API Layer: FastAPI, JWT auth, slowapi rate limiting, Redis pub/sub
- Alert Workers: python-telegram-bot, httpx (Discord webhooks) — separate processes
- Frontend: Next.js 16.2.6, TypeScript, TailwindCSS, shadcn/ui, Zustand
- Charts: TradingView Lightweight Charts v4
- Database: Supabase (PostgreSQL + TimescaleDB), Redis 7
- Observability: Sentry (Python + Next.js), Prometheus, Grafana
- Infra: Docker, Docker Compose, GitHub Actions

=== CODING STANDARDS ===
Python:
- Always use type hints (def func(x: int) -> str)
- Use Pydantic v2 for all data models
- Use asyncio / async-await throughout (no blocking calls)
- Use structlog for structured logging (not print())
- Every service must expose a /health endpoint
- Unit tests with pytest + pytest-asyncio
- 80%+ test coverage for core-engine workers

TypeScript / Next.js:
- Strict TypeScript (no `any`, no implicit types)
- Use App Router only (no pages/ directory)
- Server Components by default, Client Components only when needed
- Use React Query (TanStack Query v5) for server state
- Use Zustand for client-only state
- Use shadcn/ui + TailwindCSS for all UI components
- Unit tests with Vitest + React Testing Library

General:
- All secrets via environment variables (never hardcode)
- All inter-service communication via Redis (no direct service calls)
- Docker Compose for local development
- API versioning: all routes under /api/v1/

=== FOLDER STRUCTURE ===
crypto-whale-tracker/
├── docker-compose.yml
├── docker-compose.dev.yml
├── .env.example
├── data-layer/
│   └── python/
│       ├── collectors/
│       │   ├── exchange_ws.py       # ccxt.pro WebSocket
│       │   ├── onchain_evm.py       # web3.py
│       │   └── onchain_solana.py    # solana-py
│       ├── publishers/
│       │   └── redis_stream.py
│       └── main.py
├── core-engine/
│   ├── workers/
│   │   ├── whale_detector/
│   │   ├── onchain_monitor/
│   │   ├── ta_engine/
│   │   ├── ml_predictor/
│   │   └── signal_combiner/
│   └── shared/
├── api-layer/
│   ├── app/
│   │   ├── routers/
│   │   ├── websocket/
│   │   └── middleware/
│   └── alert-workers/
├── frontend/
│   └── src/
│       ├── app/
│       ├── components/
│       ├── hooks/
│       ├── lib/
│       └── types/
├── database/
│   └── migrations/
└── monitoring/

=== PHASE 1 TASK (Start here) ===
Build the complete DATA LAYER + WHALE DETECTOR:

1. data-layer/python/collectors/exchange_ws.py
   - Connect to Binance and Bybit via ccxt.pro WebSocket
   - Subscribe to: trades stream, liquidations stream, open interest stream
   - Filter events: trade.usd_value > WHALE_MIN_USD (from env)
   - Publish raw events to Redis Stream key: "raw:trades"
   - Handle reconnection automatically
   - Log every connection event with structlog

2. data-layer/python/publishers/redis_stream.py
   - RedisStreamPublisher class with async publish() method
   - Use aioredis, connection pooling
   - Schema: {timestamp, exchange, symbol, side, usd_value, raw_data}

3. core-engine/workers/whale_detector/detector.py
   - WhaleDetector class consuming from Redis Stream "raw:trades"
   - Detect whale events based on:
     a) Single trade > $100k USD
     b) Open Interest change > 5% in 5 min
     c) Funding rate spike > 0.1%
   - Publish confirmed whale signals to Redis pub/sub channel: "signals:whale"
   - Include confidence score (0.0 - 1.0) with each signal

4. core-engine/workers/whale_detector/tests/test_detector.py
   - Unit tests for all 3 whale detection conditions
   - Mock Redis, mock ccxt data
   - Test edge cases: exactly at threshold, just below threshold

5. docker-compose.dev.yml
   - Services: redis, data-layer, core-engine, api-layer, frontend, postgres
   - All with hot reload
   - Shared network: whale-net
   - Health checks for all services

=== SIGNAL DATA MODEL ===
All signals must follow this Pydantic schema:
class WhaleSignal(BaseModel):
    id: str                          # UUID
    timestamp: datetime
    symbol: str                      # e.g. "BTC/USDT"
    exchange: str                    # "binance" | "bybit" | "onchain"
    chain: Optional[str]             # "ethereum" | "bsc" | "solana"
    side: str                        # "long" | "short" | "unknown"
    usd_value: float
    signal_type: str                 # "large_trade" | "oi_spike" | "funding_spike"
    confidence: float                # 0.0 - 1.0
    metadata: dict                   # Raw data for debugging

=== WHAT TO AVOID ===
- No synchronous blocking code in async functions
- No hardcoded API keys or secrets
- No print() statements (use structlog)
- No `any` types in TypeScript
- No direct database calls from the data-layer
  (data-layer only writes to Redis, never to DB)
- No monolithic files > 300 lines (split into modules)

=== REVIEW PROCESS ===
After each phase, a senior engineer will review:
- Code quality and patterns
- Test coverage
- Error handling completeness
- Performance bottlenecks
- Security issues

Start with Phase 1. Ask for clarification if needed before writing code.
```

---

## 🚀 Build Phases

| Phase | Scope | Estimated Time |
|---|---|---|
| **Phase 1** | Data Layer + Whale Detector + Docker Compose | 1-2 weeks |
| **Phase 2** | TA Engine + ML Predictor (Tier 1 & 2) + FastAPI | 2-3 weeks |
| **Phase 3** | Next.js Dashboard + WebSocket real-time feed | 1-2 weeks |
| **Phase 4** | Telegram/Discord Alert Workers + User Settings | 1 week |
| **Phase 5** | ML Tier 3 (LSTM) + Backtesting UI | 2-3 weeks |
| **Phase 6** | Monitoring (Prometheus/Grafana/Sentry) + CI/CD | 1 week |

---

## ✅ Review Checklist (per Phase)

Sau mỗi phase, reviewer sẽ check:

- [ ] Type hints đầy đủ (Python) / strict TypeScript (Frontend)
- [ ] Không có hardcoded secrets
- [ ] Error handling: connection drops, invalid data, timeout
- [ ] Unit tests chạy pass
- [ ] Docker Compose spin up thành công
- [ ] Logging có structured format (structlog / JSON)
- [ ] Không có blocking calls trong async context
- [ ] Redis connection pooling (không tạo connection mới mỗi request)
- [ ] API endpoints có input validation (Pydantic / Zod)
- [ ] WebSocket có reconnection logic

---

*Architecture finalized: May 2026 | Reviewer: Claude*
