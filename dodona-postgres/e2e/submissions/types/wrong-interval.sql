SELECT title, day, CASE WHEN id = 2 THEN interval '3 days' ELSE duration END AS duration, tags FROM event ORDER BY id;
