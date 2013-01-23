--create_tables.sql

CREATE TABLE posts (
  id INTEGER PRIMARY KEY,
  rank INTEGER,
  user_id INTEGER,
  title VARCHAR(255),
  post_date DATE
);

CREATE TABLE comments (
  id INTEGER PRIMARY KEY,
  post_id INTEGER,
  user_id INTEGER,
  comment TEXT,
  comment_date DATE
);

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  screen_name VARCHAR(20),
  karma INTEGER,
  avg INTEGER
);

