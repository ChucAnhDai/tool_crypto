CREATE TABLE IF NOT EXISTS signals (
    time TIMESTAMPTZ NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    signal_type VARCHAR(50) NOT NULL,
    confidence DOUBLE PRECISION NOT NULL,
    source VARCHAR(50) NOT NULL,
    metadata JSONB
);

SELECT create_hypertable('signals', 'time', if_not_exists => TRUE);
