/*********************************************************************************************
Exercise 1: Create a subtable of orders per day. Make sure you decide whether you are
counting invoices or line items.
*********************************************************************************************/

SELECT
  date(paid_at) AS day,
  COUNT(DISTINCT invoice_id) AS orders,
  COUNT(DISTINCT line_item_id) AS line_items
FROM dsv1069.orders
GROUP BY date(paid_at);

/*********************************************************************************************
Exercise 2: “Check your joins”. We are still trying to count orders per day. In this step 
join the sub table from the previous exercise to the dates rollup table so we can get a row 
for every date. Check that the join works by just running a “select *” query
*********************************************************************************************/

WITH subtable AS 
(
SELECT
  date(paid_at) AS day,
  COUNT(DISTINCT invoice_id) AS orders,
  COUNT(DISTINCT line_item_id) AS line_items
FROM dsv1069.orders
GROUP BY date(paid_at)
)
  
SELECT
  *
FROM dsv1069.dates_rollup dr
LEFT JOIN subtable st
  ON st.day = dr.date
GROUP BY dr.date

/*********************************************************************************************
Exercise 3: “Clean up your Columns” In this step be sure to specify the columns you actually
want to return, and if necessary do any aggregation needed to get a count of the orders made
per day.
*********************************************************************************************/

WITH subtable AS 
(
SELECT
  date(paid_at) AS day,
  COUNT(DISTINCT invoice_id) AS orders,
  COUNT(DISTINCT line_item_id) AS line_items
FROM dsv1069.orders
GROUP BY date(paid_at)
)
  
SELECT
  dr.date AS day,
  COALESCE(SUM(st.orders),0) AS orders,
  COALESCE(SUM(st.items_ordered),0) AS items_ordered
FROM dsv1069.dates_rollup dr
LEFT JOIN subtable st
  ON st.day = dr.date
GROUP BY dr.date

/*********************************************************************************************
Exercise 4: Weekly Rollup. Figure out which parts of the JOIN condition need to be edited
create 7 day rolling orders table.
*********************************************************************************************/

WITH subtable AS 
(
SELECT
  date(paid_at) AS day,
  COUNT(DISTINCT invoice_id) AS orders,
  COUNT(DISTINCT line_item_id) AS line_items
FROM dsv1069.orders
GROUP BY date(paid_at)
)
  
SELECT
  *
FROM dsv1069.dates_rollup dr
LEFT JOIN subtable st
  ON st.day <= dr.date
  AND st.day > dr.d7_ago
GROUP BY dr.date

/*********************************************************************************************
Exercise 5: Column Cleanup. Finish creating the weekly rolling orders table, by performing
any aggregation steps and naming your columns appropriately.
*********************************************************************************************/

WITH subtable AS 
(
SELECT
  date(paid_at) AS day,
  COUNT(DISTINCT invoice_id) AS orders,
  COUNT(DISTINCT line_item_id) AS line_items
FROM dsv1069.orders
GROUP BY date(paid_at)
)
  
SELECT
  dr.date AS day,
  COALESCE(SUM(st.orders),0) AS orders,
  COALESCE(SUM(st.items_ordered),0) AS items_ordered
FROM dsv1069.dates_rollup dr
LEFT JOIN subtable st
  ON st.day <= dr.date
  AND st.day > dr.d7_ago
GROUP BY dr.date
