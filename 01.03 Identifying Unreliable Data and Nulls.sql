/****************************************************************************************
Exercise 1: Using any methods you like determine if you can you trust this events table.
****************************************************************************************/

SELECT
  date(event_time_) AS date,
  COUNT(*) AS rows
FROM dsv1069.events_201701
GROUP BY date(event_time);

/****************************************************************************************
Exercise 2:
Using any methods you like, determine if you can you trust this events table.
(HINT: When did we start recording events on mobile)
****************************************************************************************/

SELECT
  date(event_time_) AS date,
  platform,
  COUNT(*) AS rows
FROM dsv1069.events_ex2
GROUP BY
  date(event_time),
  platform;

/****************************************************************************************
Exercise 3: Imagine that you need to count item views by day. You found this table
item_views_by_category_temp - should you use it to answer your questiuon?
****************************************************************************************/

SELECT
  COUNT(DISTINCT event_id) AS event_count
FROM dsv1069.events
WHERE event_name = 'view_item';

/****************************************************************************************
Exercise 4: Using any methods you like, decide if this table is ready to be used as a
source of truth.
****************************************************************************************/

SELECT
  date(event_time_) AS date,
  platform,
  COUNT(user_id) AS users
FROM dsv1069.raw_events
GROUP BY
  date(event_time),
  platform;

/****************************************************************************************
Exercise 5: Is this the right way to join orders to users? Is this the right way this join.
****************************************************************************************/

SELECT
  COUNT(*)
FROM dsv1069.orders o
JOIN dsv1069.users u
  ON o.user_id = COALESCE(u.parent_user_id, u.id);
