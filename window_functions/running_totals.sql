-- running totals and cumulative sums
-- these come up constantly in financial reporting

-- basic running total
SELECT
    date,
    revenue,
    SUM(revenue) OVER (ORDER BY date) AS running_total
FROM daily_revenue;

-- running total by category (resets per category)
SELECT
    date,
    category,
    revenue,
    SUM(revenue) OVER (
        PARTITION BY category
        ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS category_running_total
FROM daily_revenue;

-- running 7-day average
SELECT
    date,
    revenue,
    AVG(revenue) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7d_avg
FROM daily_revenue;

-- month-to-date total (resets every month)
SELECT
    date,
    revenue,
    SUM(revenue) OVER (
        PARTITION BY DATE_TRUNC('month', date)
        ORDER BY date
    ) AS mtd_revenue
FROM daily_revenue;

-- percent of total
SELECT
    category,
    revenue,
    revenue / SUM(revenue) OVER () * 100 AS pct_of_total
FROM category_revenue;
