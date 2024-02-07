/*****************************************************************************************
Exercise 1: We’ll be using the users table to answer the question “How many new users are
added each day?“. Start by making sure you understand the columns in the table.
*****************************************************************************************/

SELECT
  id,
  parent_user_id,
  merged_at
FROM dsv1069.users
ORDER BY parent_user_id ASC;

/*****************************************************************************************
Exercise 2: Without worrying about deleted user or merged users, count the number of users
added each day.
*****************************************************************************************/

SELECT
  date(created_at) AS day,
  COUNT(*) AS users
FROM dsv1069.users
GROUP BY date(created_at);

/*****************************************************************************************
Exercise 3: Consider the following query. Is this the right way to count merged or deleted
users? If all of our users were deleted tomorrow what would the result look like?
*****************************************************************************************/

SELECT
  date(created_at) AS day,
  COUNT(*) AS users
FROM dsv1069.users
WHERE deleted_at IS NULL
  AND (id <> parent_user_id OR parent_user_id IS NULL)
GROUP BY date(created_at);

/*****************************************************************************************
Exercise 4: Count the number of users deleted each day. Then count the number of users
removed due to merging in a similar way.
*****************************************************************************************/

SELECT
  date(deleted_at) AS day,
  COUNT(*) AS deleted_users
FROM dsv1069.users
WHERE deleted_at IS NULL
GROUP BY date(deleted_at);

/*****************************************************************************************
Exercise 5: Use the pieces you’ve built as subtables and create a table that has a column for
the date, the number of users created, the number of users deleted and the number of users
merged that day.
*****************************************************************************************/

WITH Created AS
(
SELECT
  date(created_at) AS day,
  COUNT(*) AS new_users_added
FROM dsv1069.users
GROUP BY date(created_at)
),

Deleted AS 
(
SELECT
  date(deleted_at) AS day,
  COUNT(*) AS deleted_users
FROM dsv1069.users
WHERE deleted_at IS NULL
GROUP BY date(deleted_at)
),

Merged AS
(
SELECT
  date(merged_at) AS day,
  COUNT(*) AS merged_users
FROM dsv1069.users
WHERE id <> parent_user_id
  AND parent_user_id IS NULL
GROUP BY date(merged_at)
)
  
SELECT
  c.day,
  c.new_users_added,
  d.deleted_users,
  m.merged_users
FROM Created c
JOIN Deleted d
  ON d.day = c.day
LEFT JOIN Merged m
  ON m.day = c.day

/*****************************************************************************************
Exercise 6: Refine your query from #5 to have informative column names and so that null
columns return 0.
*****************************************************************************************/

WITH Created AS
(
SELECT
  date(created_at) AS day,
  COUNT(*) AS new_users_added
FROM dsv1069.users
GROUP BY date(created_at)
),

Deleted AS 
(
SELECT
  date(deleted_at) AS day,
  COUNT(*) AS deleted_users
FROM dsv1069.users
WHERE deleted_at IS NULL
GROUP BY date(deleted_at)
),

Merged AS
(
SELECT
  date(merged_at) AS day,
  COUNT(*) AS merged_users
FROM dsv1069.users
WHERE id <> parent_user_id
  AND parent_user_id IS NULL
GROUP BY date(merged_at)
)
  
SELECT
  c.day,
  c.new_users_added,
  COALESCE(d.deleted_users,0) AS deleted_users,
  COALESCE(m.merged_users,0) AS merged_users,
  (c.new_users_added - COALESCE(d.deleted_users,0) - COALESCE(m.merged_users,0)) AS net_added_users
FROM Created c
JOIN Deleted d
  ON d.day = c.day
LEFT JOIN Merged m
  ON m.day = c.day

/*****************************************************************************************
Exercise 7: What if there were days where no users were created, but some users were deleted
or merged. Does the previous query still work? No, it doesn’t. Use the dates_rollup as a 
backbone for this query, so that we won’t miss any dates.
*****************************************************************************************/

SELECT
  *
FROM dsv1069.dates_rollup
