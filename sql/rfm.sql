-- RFM segmentation - every cut-off is a parameter, nothing hard-coded.
-- Tested on PostgreSQL 14+; window functions only, so it ports to BigQuery,
-- MySQL 8 and SQL Server with minimal changes.

WITH params AS (
    SELECT
        DATE '2026-01-01' AS period_start,
        DATE '2026-12-31' AS period_end,
        5                 AS tiers,        -- quintiles by default
        1                 AS min_orders    -- ignore single-touch noise if needed
),

customer_base AS (
    SELECT
        o.customer_id,
        MAX(o.order_date)                        AS last_order_date,
        COUNT(DISTINCT o.order_id)               AS order_count,
        SUM(o.order_value)                       AS total_value
    FROM orders o, params p
    WHERE o.order_date BETWEEN p.period_start AND p.period_end
      AND o.status = 'completed'
    GROUP BY o.customer_id
    HAVING COUNT(DISTINCT o.order_id) >= (SELECT min_orders FROM params)
),

rfm_raw AS (
    SELECT
        cb.customer_id,
        (SELECT period_end FROM params) - cb.last_order_date AS recency_days,
        cb.order_count                                        AS frequency,
        cb.total_value                                        AS monetary,
        cb.total_value / NULLIF(cb.order_count, 0)            AS avg_basket
    FROM customer_base cb
),

rfm_scored AS (
    SELECT
        r.*,
        -- recency reversed: fewer days since last order is a better score
        NTILE((SELECT tiers FROM params)) OVER (ORDER BY r.recency_days DESC) AS r_score,
        NTILE((SELECT tiers FROM params)) OVER (ORDER BY r.frequency     ASC) AS f_score,
        NTILE((SELECT tiers FROM params)) OVER (ORDER BY r.monetary      ASC) AS m_score
    FROM rfm_raw r
),

segments AS (
    SELECT
        s.*,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal'
            WHEN r_score >= 4 AND f_score <= 2                  THEN 'Potential'
            WHEN r_score <= 2 AND f_score >= 3                  THEN 'At risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Need attention'
            ELSE 'Others'
        END AS segment
    FROM rfm_scored s
)

SELECT
    segment,
    COUNT(*)                                   AS customers,
    ROUND(AVG(frequency), 2)                   AS avg_frequency,
    ROUND(AVG(avg_basket), 0)                  AS avg_basket,
    ROUND(SUM(monetary), 0)                    AS segment_value,
    ROUND(100.0 * SUM(monetary)
          / SUM(SUM(monetary)) OVER (), 1)     AS pct_of_revenue
FROM segments
GROUP BY segment
ORDER BY segment_value DESC;

-- The finding this query was built to test:
-- compare avg_basket between Champions and Loyal at the same avg_frequency.
-- If basket differs and frequency does not, the lever is basket size, not visits.
