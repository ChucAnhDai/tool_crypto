# HANDOFF — tool_crypto
Generated: 2026-05-21

## STACK DECISIONS (final, do not change)
- Python 3.12 + asyncio + ccxt.pro
- web3.py (EVM) + solana-py (Solana)
- Redis 7 Streams (queue) + Pub/Sub (broadcast)
- FastAPI + slowapi + JWT
- Next.js 16.2.6 + TypeScript + TailwindCSS + shadcn/ui
- Supabase PostgreSQL (auth/config) + TimescaleDB Docker (time-series)
- Prometheus + Grafana + Sentry
- GitHub Actions CI/CD

## PROGRESS LOG
| Prompt | Task | Commit | Status |
|--------|------|--------|--------|
| #1 | Scaffold folder structure (43 folders, 150 files) | 49b09c9 | ✅ Done |
| #2 | Git init + GitHub repo + .gitignore | 49b09c9 | ✅ Done |
| #3 | docker-compose.dev.yml (7 services) | da0fd26 | ✅ Done |
| #4 | Dockerfiles (data-layer, core-engine, api-layer, frontend) | 78e97bf | ✅ Done |
| #5 | DB migrations written (006 files) | pending | ✅ Done |
| #5 | Supabase tables (users, alert_configs, backtest_runs, backtest_results) | - | ❌ NOT DONE |

## FILES STATUS
### Empty (waiting for code):
- data-layer/python/collectors/exchange_ws.py
- data-layer/python/collectors/onchain_evm.py
- data-layer/python/collectors/onchain_solana.py
- data-layer/python/publishers/redis_stream.py
- core-engine/workers/whale_detector/detector.py
- core-engine/workers/whale_detector/filters.py
- api-layer/app/main.py
- api-layer/alert-workers/telegram_worker.py
- frontend/src/app/layout.tsx
- frontend/src/app/page.tsx

### Config files (complete):
- docker-compose.dev.yml ✅
- data-layer/python/Dockerfile ✅
- core-engine/Dockerfile ✅
- api-layer/Dockerfile ✅
- frontend/Dockerfile ✅
- database/migrations/001-006 ✅

### Still empty (next prompts):
- All requirements.txt files
- All package.json
- All source .py and .ts files

## ENVIRONMENT VARS NEEDED
(names only — values in .env locally, never committed)
- BINANCE_API_KEY / BINANCE_API_SECRET
- BYBIT_API_KEY / BYBIT_API_SECRET
- ETH_RPC_URL / BSC_RPC_URL / ARBITRUM_RPC_URL / BASE_RPC_URL / SOLANA_RPC_URL
- REDIS_URL
- SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_KEY
- DATABASE_URL
- JWT_SECRET
- TELEGRAM_BOT_TOKEN / TELEGRAM_CHAT_ID
- DISCORD_WEBHOOK_URL
- SENTRY_DSN_PYTHON / SENTRY_DSN_NEXTJS
- WHALE_MIN_USD=100000
- WHALE_OI_CHANGE_PCT=5
- WHALE_FUNDING_THRESHOLD=0.1

## PENDING TASKS (next chat)
1. Create Supabase tables via MCP (users, alert_configs, backtest_runs, backtest_results + RLS)
2. Write requirements.txt for all 3 Python services
3. Write frontend package.json with all dependencies
4. Code: data-layer collectors (exchange_ws.py, onchain_evm.py)
5. Code: Redis stream publisher (redis_stream.py)
6. Code: Whale detector (detector.py + filters.py)

## GITHUB REPO
https://github.com/ChucAnhDai/tool_crypto

## HOW TO CONTINUE IN NEW CHAT
Paste this entire HANDOFF.md and say:
"Project tool_crypto đang làm dở.
Đọc HANDOFF.md này và tiếp tục từ PENDING TASKS.
Không hỏi lại những gì đã có trong file.
Reference file đầy đủ: CRYPTO_WHALE_TRACKER.md trong project."
