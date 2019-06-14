-- join patterns beyond the basics

-- anti join: find users with no orders
-- (LEFT JOIN + WHERE NULL is faster than NOT IN on most engines)
SELECT u.*
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.user_id IS NULL;

-- self join: find employees who earn more than their manager
SELECT
    e.name AS employee,
    e.salary AS employee_salary,
    m.name AS manager,
    m.salary AS manager_salary
FROM employees e
INNER JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- inequality join: find overlapping date ranges
-- (who was on vacation at the same time?)
SELECT
    a.employee AS emp_a,
    b.employee AS emp_b,
    GREATEST(a.start_date, b.start_date) AS overlap_start,
    LEAST(a.end_date, b.end_date) AS overlap_end
FROM vacations a
INNER JOIN vacations b
    ON a.employee < b.employee  -- avoid self-match and duplicates
    AND a.start_date <= b.end_date
    AND a.end_date >= b.start_date;

-- lateral join: top 3 most recent orders per user
-- (postgres specific but extremely useful)
SELECT u.id, u.name, recent.*
FROM users u
CROSS JOIN LATERAL (
    SELECT order_id, total, created_at
    FROM orders o
    WHERE o.user_id = u.id
    ORDER BY created_at DESC
    LIMIT 3
) recent;
