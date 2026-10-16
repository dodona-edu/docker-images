CREATE SCHEMA shop;

CREATE TABLE shop.product (
  id int PRIMARY KEY,
  name text NOT NULL,
  price numeric(6,2) NOT NULL
);
INSERT INTO shop.product VALUES (1, 'apple', 0.50), (2, 'pear', 0.75), (3, 'kiwi', 1.20), (4, 'mango', 2.10);

CREATE TABLE shop.event (
  id int PRIMARY KEY,
  title text NOT NULL,
  day date,
  duration interval,
  tags text[]
);
INSERT INTO shop.event VALUES
  (1, 'opening', '2026-01-15', '1 hour 30 minutes', ARRAY['party', 'public']),
  (2, 'workshop', '2026-02-01', '2 days', ARRAY['staff']),
  (3, 'closing', NULL, NULL, NULL);

CREATE ROLE student LOGIN PASSWORD 'student';
GRANT USAGE ON SCHEMA shop TO student;
GRANT SELECT ON ALL TABLES IN SCHEMA shop TO student;
