-- recursive CTE for org hierarchy / tree structures
-- useful for manager→report chains, category trees, etc.

-- org chart: find all reports under a manager
WITH RECURSIVE org_tree AS (
    -- anchor: start with the manager
    SELECT
        employee_id,
        name,
        manager_id,
        1 AS depth,
        name AS path
    FROM employees
    WHERE employee_id = 100  -- starting manager

    UNION ALL

    -- recursive: find direct reports
    SELECT
        e.employee_id,
        e.name,
        e.manager_id,
        t.depth + 1,
        t.path || ' > ' || e.name
    FROM employees e
    INNER JOIN org_tree t ON e.manager_id = t.employee_id
    WHERE t.depth < 10  -- safety limit
)
SELECT * FROM org_tree ORDER BY depth, name;


-- chained CTEs (not recursive, just readable)
-- break complex queries into steps
WITH
active_users AS (
    SELECT user_id, signup_date
    FROM users
    WHERE status = 'active'
    AND last_login >= CURRENT_DATE - INTERVAL '30 days'
),
user_orders AS (
    SELECT
        u.user_id,
        u.signup_date,
        COUNT(o.order_id) AS order_count,
        SUM(o.total) AS total_spent
    FROM active_users u
    LEFT JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.signup_date
),
user_segments AS (
    SELECT
        *,
        CASE
            WHEN total_spent > 1000 THEN 'high_value'
            WHEN total_spent > 100  THEN 'mid_value'
            WHEN order_count > 0    THEN 'low_value'
            ELSE 'no_orders'
        END AS segment
    FROM user_orders
)
SELECT
    segment,
    COUNT(*) AS user_count,
    AVG(order_count) AS avg_orders,
    AVG(total_spent) AS avg_spent
FROM user_segments
GROUP BY segment
ORDER BY avg_spent DESC;
