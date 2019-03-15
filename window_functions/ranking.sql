-- ranking patterns

-- row_number vs rank vs dense_rank
-- row_number: 1,2,3,4 (no ties)
-- rank:       1,2,2,4 (ties skip)
-- dense_rank: 1,2,2,3 (ties don't skip)

-- top N per group (classic interview question)
-- "get the top 3 products by revenue in each category"
WITH ranked AS (
    SELECT
        category,
        product,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS rn
    FROM products
)
SELECT * FROM ranked WHERE rn <= 3;

-- first and last per group
-- "when was each user's first and most recent purchase?"
SELECT DISTINCT
    user_id,
    FIRST_VALUE(purchase_date) OVER (
        PARTITION BY user_id ORDER BY purchase_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_purchase,
    LAST_VALUE(purchase_date) OVER (
        PARTITION BY user_id ORDER BY purchase_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_purchase
FROM purchases;

-- lag/lead for comparing to previous/next row
-- "show each day's revenue alongside yesterday's"
SELECT
    date,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY date) AS prev_day_revenue,
    revenue - LAG(revenue, 1) OVER (ORDER BY date) AS day_over_day_change
FROM daily_revenue;
