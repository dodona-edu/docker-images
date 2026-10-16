SELECT title, day, duration, CASE WHEN id = 1 THEN ARRAY['party'] ELSE tags END AS tags FROM event ORDER BY id;
