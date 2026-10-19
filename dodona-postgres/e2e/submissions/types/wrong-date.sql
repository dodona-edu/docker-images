SELECT title, CASE WHEN id = 1 THEN date '2026-01-16' ELSE day END AS day, duration, tags FROM event ORDER BY id;
