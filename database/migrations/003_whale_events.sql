CREATE TABLE IF NOT EXISTS whale_events (
    time TIMESTAMPTZ NOT NULL,
    tx_hash VARCHAR(100),
    chain VARCHAR(50) NOT NULL,
    wallet VARCHAR(100) NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    side VARCHAR(10) NOT NULL,
    usd_value DOUBLE PRECISION NOT NULL,
    exchange VARCHAR(50) NOT NULL
);

SELECT create_hypertable('whale_events', 'time', if_not_exists => TRUE);
