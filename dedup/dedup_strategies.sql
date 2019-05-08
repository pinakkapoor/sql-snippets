-- deduplication patterns
-- pick the strategy based on which row you want to keep

-- strategy 1: keep the latest row per key
-- (most common — keep the most recent record)
DELETE FROM events
WHERE id NOT IN (
    SELECT MAX(id)
    FROM events
    GROUP BY event_type, user_id, DATE(created_at)
);

-- strategy 2: keep first occurrence using row_number
-- non-destructive version (creates a clean view)
WITH deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, event_type
            ORDER BY created_at ASC
        ) AS rn
    FROM events
)
SELECT * FROM deduped WHERE rn = 1;

-- strategy 3: exact duplicate removal (all columns match)
-- find them first
SELECT
    user_id, event_type, created_at,
    COUNT(*) AS dupe_count
FROM events
GROUP BY user_id, event_type, created_at
HAVING COUNT(*) > 1;

-- strategy 4: fuzzy temporal dedup
-- events within 5 minutes of each other for the same user = probably dupes
-- (this is the one i ended up needing most at work)
WITH time_diffs AS (
    SELECT
        *,
        LAG(created_at) OVER (
            PARTITION BY user_id, event_type
            ORDER BY created_at
        ) AS prev_event_at,
        EXTRACT(EPOCH FROM (
            created_at - LAG(created_at) OVER (
                PARTITION BY user_id, event_type
                ORDER BY created_at
            )
        )) AS seconds_since_prev
    FROM events
)
SELECT *
FROM time_diffs
WHERE seconds_since_prev IS NULL  -- first occurrence
   OR seconds_since_prev > 300;   -- more than 5 min gap
