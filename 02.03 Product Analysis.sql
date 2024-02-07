/****************************************************************
Exercise 1: Find out how many users have ever ordered
****************************************************************/

SELECT
  COUNT(DISTINCT user_id) AS users_with_orders
FROM dsv1069.orders

/****************************************************************
Exercise 2: Goal find how many users have reordered the same item
****************************************************************/

WITH timesordered AS
(
SELECT
  user_id,
  item_id,
  COUNT(DISTINCT line_item_id) AS time_user_ordered
FROM dsv1069.orders
GROUP BY
  user_id,
  item_id
)
  
SELECT
  COUNT(DISTINCT user_id) AS users_who_ordered
FROM timesordered
WHERE times_user_ordered > 1

/****************************************************************
Exercise 3: Do users even order more than once?
****************************************************************/

WITH user_level AS
(
SELECT
  user_id,
  COUNT(DISTINCT invoice_id) AS order_count
FROM dsv1069.users
GROUP BY user_id
)

SELECT 
  COUNT(DISTINCT user_id)
FROM user_level
WHERE order_count > 1

/****************************************************************
Exercise 4: Orders per item
****************************************************************/

SELECT
  item_id,
  COUNT(line_item_id) AS times_ordered
FROM dsv1069.orders
GROUP BY item_id

/****************************************************************
Exercise 5: Orders per category
****************************************************************/

SELECT
  item_category,
  COUNT(line_item_id) AS times_category_ordered
FROM dsv1069.orders
GROUP BY item_category

/****************************************************************
Exercise 6: Do user order multiple things from the same category?
****************************************************************/

WITH user_level AS
(
SELECT
  user_id,
  item_category,
  COUNT(line_item_id) AS times_category_ordered
FROM dsv1069.orders
GROUP BY 
  user_id,
  item_category
)

SELECT
  item_category,
  AVG(times_category_ordered) AS avg_time_category_ordered
FROM user_level
GROUP BY item_category

/****************************************************************
Exercise 7: Find the average time between orders
Decide if this analysis is necessary
****************************************************************/

WITH first_orders AS
(
SELECT
  user_id,
  invoice_id,
  paid_at,
  DENSE_RANK() OVER (PARTITION BY user_id ORDER BY paid_at ASC) AS order_num
FROM dsv1069.orders
),
  
second_orders AS
(
SELECT
  user_id,
  invoice_id,
  paid_at,
  DENSE_RANK() OVER (PARTITION BY user_id ORDER BY paid_at ASC) AS order_num
FROM dsv1069.orders
)

SELECT
  fo.user_id,
  date(fo.paid_at) AS first_order_date,
  date(so.paid_at) AS second_order_date,
  date(so.paid_at) - date(fo.paid_at) AS date_diff
FROM first_orders fo
JOIN second_orders so
  ON fo.user_id = so.user_id
WHERE fo.order_num = 1
  AND so.order_num = 2
