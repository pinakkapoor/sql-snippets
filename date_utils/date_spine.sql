-- date spine generator
-- creates a continuous series of dates so you don't have gaps
-- in time series analysis when some days have no data

-- postgres
WITH date_spine AS (
    SELECT generate_series(
        '2019-01-01'::date,
        CURRENT_DATE,
        '1 day'::interval
    )::date AS date
)
SELECT
    ds.date,
    COALESCE(r.revenue, 0) AS revenue,
    COALESCE(r.orders, 0) AS orders
FROM date_spine ds
LEFT JOIN daily_metrics r ON ds.date = r.date
ORDER BY ds.date;


-- cohort bucketing by signup week
SELECT
    DATE_TRUNC('week', signup_date) AS cohort_week,
    DATE_TRUNC('week', activity_date) AS activity_week,
    COUNT(DISTINCT user_id) AS active_users
FROM user_activity
GROUP BY 1, 2
ORDER BY 1, 2;


-- fiscal quarter mapping (assuming fiscal year starts april)
SELECT
    date,
    CASE
        WHEN EXTRACT(MONTH FROM date) >= 4 THEN EXTRACT(YEAR FROM date)
        ELSE EXTRACT(YEAR FROM date) - 1
    END AS fiscal_year,
    CASE
        WHEN EXTRACT(MONTH FROM date) BETWEEN 4 AND 6   THEN 'Q1'
        WHEN EXTRACT(MONTH FROM date) BETWEEN 7 AND 9   THEN 'Q2'
        WHEN EXTRACT(MONTH FROM date) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END AS fiscal_quarter
FROM transactions;
