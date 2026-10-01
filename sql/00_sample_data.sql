-- Minimal synthetic schema so rfm.sql runs out of the box. No real data.
-- Re-runnable on purpose: a reviewer who runs `make test` twice should not
-- meet a duplicate-key error on the second go.
SET client_min_messages = warning;
DROP TABLE IF EXISTS orders CASCADE;

CREATE TABLE orders (
    order_id     BIGINT PRIMARY KEY,
    customer_id  BIGINT      NOT NULL,
    order_date   DATE        NOT NULL,
    order_value  NUMERIC(12,2) NOT NULL,
    status       TEXT        NOT NULL DEFAULT 'completed'
);

INSERT INTO orders (order_id, customer_id, order_date, order_value, status) VALUES
 (1, 101, DATE '2026-11-20', 480000, 'completed'),
 (2, 101, DATE '2026-12-02', 520000, 'completed'),
 (3, 101, DATE '2026-12-18', 610000, 'completed'),
 (4, 102, DATE '2026-03-11', 180000, 'completed'),
 (5, 102, DATE '2026-04-02', 150000, 'completed'),
 (6, 103, DATE '2026-12-21', 240000, 'completed'),
 (7, 104, DATE '2026-07-09', 890000, 'completed'),
 (8, 104, DATE '2026-09-30', 910000, 'completed'),
 (9, 105, DATE '2026-01-14',  95000, 'completed'),
(10, 105, DATE '2026-02-01',  88000, 'cancelled');
