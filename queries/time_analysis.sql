----------------------------- TIME & CUSTOMER BEHAVIOUR ANALYSIS -------------------------

-- Which day of the week generates the highest number of orders?
SELECT DAYNAME(order_date) AS Day_of_Week, COUNT(DISTINCT order_id) AS Total_Orders  FROM orders
GROUP BY Day_of_Week
ORDER BY Total_Orders DESC;


-- Which month generates the highest revenue?
SELECT MONTHNAME(order_date) AS Month_Name, ROUND(SUM(pizzas.price * order_details.quantity),2) AS Total_Revenue FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY Month_Name 
ORDER BY Total_Revenue DESC;


-- What are the peak ordering hours of the day?
SELECT Time_Label, Total_Orders FROM
(SELECT HOUR(order_time) AS hourr, DATE_FORMAT(order_time,'%l %p') AS Time_Label, 
COUNT(DISTINCT order_id) AS Total_Orders
FROM orders
GROUP BY hourr, Time_Label
ORDER BY hourr) AS d;


-- What is the average order value per day?
SELECT orders.order_date AS Dayy, ROUND(SUM(pizzas.price * order_details.quantity)  / 
COUNT(DISTINCT order_details.order_id), 2) AS Average_Order_Value FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY Dayy
ORDER BY Dayy;


-- How does total revenue accumulate over time?
WITH g AS (SELECT MONTH(order_date) AS Month_Number,
MONTHNAME(order_date) AS Month_Name, ROUND(SUM(pizzas.price * order_details.quantity),2)
AS Total_Revenue FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY Month_Number, Month_Name)
SELECT Month_Name, ROUND(SUM(Total_Revenue) OVER(ORDER BY Month_Number), 2) AS Cumulative_Revenue FROM g;


-- How do customer ordering patterns vary throughout the day (Morning, Afternoon, Evening, Night)?
WITH k AS (SELECT HOUR(order_time) AS hourr, COUNT(DISTINCT(order_id)) AS Total_Orders
FROM orders
GROUP BY hourr
ORDER BY hourr),
p AS (SELECT *, CASE
WHEN hourr BETWEEN 9 AND 11 THEN "Morning"
WHEN hourr BETWEEN 12 AND 16 THEN "Afternoon"
WHEN hourr BETWEEN 17 AND 19 THEN "Evening"
ELSE "Night" END AS Timee
FROM k)
SELECT Timee, SUM(Total_Orders) AS Orders FROM p
GROUP BY Timee;


-- How does revenue change Month-over-Month?
WITH cte AS (SELECT YEAR(order_date) AS Yearr, MONTH(order_date) AS Month_Number,
ROUND(SUM(pizzas.price * order_details.quantity),2) AS Total_Revenue FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY Yearr, Month_Number)

SELECT Yearr, Month_Number, Total_Revenue,
LAG(Total_Revenue) OVER(ORDER BY yearr, Month_Number) AS Previous_Month_Revenue, 
ROUND(Total_Revenue - LAG(Total_Revenue) OVER(ORDER BY yearr, Month_Number), 2) AS MoM_Change,
ROUND(((Total_Revenue - LAG(Total_Revenue) OVER(ORDER BY Yearr, Month_Number)) 
/ LAG(Total_Revenue) OVER(ORDER BY Yearr, Month_Number)) * 100, 2) AS MoM_Percent_Change FROM cte;
