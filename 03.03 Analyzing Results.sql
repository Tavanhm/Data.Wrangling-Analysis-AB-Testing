/*********************************************************************************************
Exercise 1: Use the order_binary metric from the previous exercise, count the number of users
per treatment group for test_id = 7, and count the number of users with orders
*********************************************************************************************/

WITH Testevent AS
(
SELECT
  event_id,
  event_time,
  user_id,
  MAX(CASE WHEN parameter_name = 'test_id'
        THEN CAST(parameter_value AS INT)
        ELSE NULL
      END) AS test_id,
  MAX(CASE WHEN parameter_name = 'test_assignment'
        THEN CAST(parameter_value AS INT)
        ELSE NULL
      END) AS test_assignment
FROM dsv1069.events
WHERE event_name = 'test_assignment'
GROUP BY
  event_id,
  event_time,
  user_id
)

SELECT
  test_assignment,
  COUNT(user_id) AS users,
  SUM(order_binary) AS orders_completed
FROM
  (SELECT
  te.test_id,
  te.test_assignment,
  te.user_id,
  MAX(CASE WHEN o.created_at > te.event_time THEN 1 ELSE 0 END) AS orders_after_assignment_binary
FROM Testevent te
LEFT JOIN dsv1069.orders o
  ON te.user_id = o.user_id
GROUP BY
  te.test_id,
  te.test_assignment,
  te.user_id
) as order_binary
WHERE test_id = 7
GROUP BY test_assighment

/*********************************************************************************************
Exercise 2: Create a new tem view binary metric. Count the number of users per treatment
group, and count the number of users with views
*********************************************************************************************/

WITH Testevent AS
(
  SELECT
    event_id,
    event_time,
    user_id,
    MAX(CASE WHEN parameter_name = 'test_id'
          THEN CAST(parameter_value AS INT)
          ELSE NULL
        END) AS test_id,
    MAX(CASE WHEN parameter_name = 'test_assignment'
          THEN CAST(parameter_value AS INT)
          ELSE NULL
        END) AS test_assignment
  FROM dsv1069.events
  WHERE event_name = 'test_assignment'
  GROUP BY
    event_id,
    event_time,
    user_id
)

SELECT
  test_assignment,
  COUNT(user_id) AS users,
  SUM(order_binary) AS orders_completed
FROM
  (
    SELECT
      te.test_id,
      te.test_assignment,
      te.user_id,
      MAX(CASE WHEN views.event_time > te.event_time THEN 1 ELSE 0 END) AS view_binary
    FROM Testevent te
    LEFT JOIN 
      (
        SELECT *
        FROM dsv1069.events
        WHERE event_name = 'view_item'
      ) views
      ON view.user_id = o.user_id
    GROUP BY
      te.test_id,
      te.test_assignment,
      te.user_id
  ) as order_binary
WHERE test_id = 7
GROUP BY test_assighment

/*********************************************************************************************
Exercise 3: Alter the result from EX 2, to compute the users who viewed an item WITHIN 30
days of their treatment event
*********************************************************************************************/

WITH Testevent AS
(
  SELECT
    event_id,
    event_time,
    user_id,
    MAX(CASE WHEN parameter_name = 'test_id'
          THEN CAST(parameter_value AS INT)
          ELSE NULL
        END) AS test_id,
    MAX(CASE WHEN parameter_name = 'test_assignment'
          THEN CAST(parameter_value AS INT)
          ELSE NULL
        END) AS test_assignment
  FROM dsv1069.events
  WHERE event_name = 'test_assignment'
  GROUP BY
    event_id,
    event_time,
    user_id
)

SELECT
  test_assignment,
  COUNT(user_id) AS users,
  SUM(order_binary) AS orders_completed
FROM
  (
    SELECT
      te.test_id,
      te.test_assignment,
      te.user_id,
      MAX(CASE WHEN views.event_time > te.event_time THEN 1 ELSE 0 END) AS view_binary,
      MAX(CASE WHEN (views.event_time > te.event_time
                AND DATE_PART('day', views.event_time - te.event_time) <= 30)
                THEN 1 ELSE 0 END) AS views_binary_30d
    FROM Testevent te
    LEFT JOIN 
      (
        SELECT *
        FROM dsv1069.events
        WHERE event_name = 'view_item'
      ) views
      ON view.user_id = o.user_id
    GROUP BY
      te.test_id,
      te.test_assignment,
      te.user_id
  ) as order_binary
WHERE test_id = 7
GROUP BY test_assighment

/*********************************************************************************************
Create the metric invoices (this is a mean metric, not a binary metric) and for test_id = 7
1) The count of users per treatment group
2) The average value of the metric per treatment group
3) The standard deviation of the metric per treatment group
*********************************************************************************************/

WITH testassignments AS
(
    SELECT
      event_id,
      event_time,
      MAX(CASE WHEN parameter_name = 'test_id'
            THEN CAST(parameter_value AS INT)
            ELSE NULL
          END) AS test_id,
      MAX(CASE WHEN parameter_name = 'test_assignment'
            THEN CAST(parameter_value AS INT)
            ELSE NULL
          END) AS test_assignment
    FROM dsv1069.events
    WHERE event_name = 'test_assignment'
    GROUP BY
      event_id,
      event_time,
      user_id
    ORDER BY event_id
),

mean_metrics AS
(
SELECT
  te.user_id,
  te.test_id,
  te.test_assignment,
  COUNT(DISTINCT CASE WHEN o.created_at > te.event_time THEN o.invoice_id ELSE NULL END) AS invoices,
  COUNT(DISTINCT CASE WHEN o.created_at > te.event_time THEN o.line_item_id ELSE NULL END) AS line_items
  COALESCE(SUM(CASE WHEN o.created_at > te.event_time THEN o.price ELSE 0 END), 0) AS total_revenue
FROM testassignments te
LEFT JOIN dsv1069.orders o
  ON  te.user_id = o.user_id
GROUP BY 
  te.user_id,
  te.test_id,
  te.test_assignment
)

SELECT
  test_id,
  test_assignment,
  COUNT(user_id) AS users,
  AVG(invoices) AS avg_invoices,
  STD(invoices) AS stddev_invoices
FROM mean_metrics
GROUP BY test_id
ORDER BY test_id
