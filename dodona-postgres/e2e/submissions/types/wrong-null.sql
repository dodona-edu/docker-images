SELECT title, CASE WHEN id = 3 THEN date '2026-03-01' ELSE day END AS day, duration, tags FROM event ORDER BY id;
