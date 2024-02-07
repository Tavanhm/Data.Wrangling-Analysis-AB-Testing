/*******************************************************************************
Exercise 1:
Using the table from Exercise 4.3 and compute a metric that measures
Whether a user created an order after their test assignment
Requirements: Even if a user had zero orders, we should have a row that counts
their number of orders as zero
If the user is not in the experiment they should not be included
*******************************************************************************/

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

/*******************************************************************************
Exercise 2:
Using the table from the previous exercise, add the following metrics
1) the number of orders/invoices
2) the number of items/line-items ordered
3) the total revenue from the order after treatment
*******************************************************************************/

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
  te.test_id,
  te.test_assignment,
  te.user_id,
  COUNT(DISTINCT(CASE WHEN o.created_at > te.event_time THEN o.invoice_id ELSE NULL END)) AS orders_after_assignment,
  COUNT(DISTINCT(CASE WHEN o.created_at > te.event_time THEN o.line_item_id ELSE NULL END)) AS items_after_assignment,
  SUM(CASE WHEN o.created_at > te.event_time THEN o.price ELSE 0 END) AS total_revenue
FROM Testevent te
LEFT JOIN dsv1069.orders o
  ON te.user_id = o.user_id
GROUP BY
  te.test_id,
  te.test_assignment,
  te.user_id
