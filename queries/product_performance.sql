----------------------------- PRODUCT PERFORMANCE ANALYSIS --------------------------------

-- Which pizzas generate the highest total revenue?
SELECT pizza_types.name, ROUND(SUM(pizzas.price * order_details.quantity),2) AS Total_Revenue FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Total_Revenue DESC;


-- What are the top 5 best-selling pizzas based on total quantity sold?
SELECT pizza_types.name, SUM(quantity) AS Total_QTY_Sold FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Total_QTY_Sold DESC
LIMIT 5;


-- What are the bottom 5 least-selling pizzas?
SELECT pizza_types.name, SUM(quantity) AS Total_QTY_Sold FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Total_QTY_Sold
LIMIT 5;


-- Which pizza sizes are the most popular among customers?
SELECT pizzas.size, SUM(quantity) AS Total_QTY_Sold FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizzas.size
ORDER BY Total_QTY_Sold DESC;


-- Rank all pizzas based on total revenue
WITH l AS (SELECT pizza_types.name, ROUND(SUM(pizzas.price * order_details.quantity),2) AS Total_Revenue FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name)
SELECT *, RANK() OVER(ORDER BY Total_Revenue DESC)  AS rnk FROM l;


-- What are the top 3 best-selling pizzas within each category?
WITH cte AS (SELECT pizza_types.category, pizza_types.name,
ROUND(SUM(pizzas.price * order_details.quantity),2) AS Total_Revenue FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category,pizza_types.name ),
c AS  (SELECT category, name, Total_Revenue, DENSE_RANK() OVER(PARTITION BY category ORDER BY Total_Revenue DESC) AS rnk FROM cte)
SELECT * FROM c
WHERE rnk <= 3;


-- What percentage of total revenue does each pizza contribute?
WITH rev AS (SELECT pizza_types.name, ROUND(SUM(pizzas.price * order_details.quantity),2) AS Total_Revenue FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name)
SELECT name,  ROUND(Total_Revenue * 100 / SUM(Total_Revenue)  OVER(), 2) AS Percentage_Contribution FROM  rev
ORDER BY Percentage_Contribution DESC;


-- Which pizza size is the most popular within each category?
WITH cte AS (SELECT pizza_types.category, pizzas.size, SUM(quantity) AS Total_QTY_Sold FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category,pizzas.size ),
c AS  (SELECT category, size, Total_QTY_Sold, DENSE_RANK() OVER(PARTITION BY category ORDER BY Total_QTY_Sold DESC) AS rnk FROM cte) 
SELECT category, size, Total_QTY_Sold FROM c
WHERE rnk = 1;


-- Which pizzas generate revenue above the average pizza revenue?
WITH h AS (SELECT pizza_types.name, ROUND(SUM(pizzas.price * order_details.quantity), 2) AS Total_Revenue FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name)
SELECT * FROM h
WHERE Total_Revenue > (SELECT AVG(Total_Revenue) FROM h)
ORDER BY Total_Revenue DESC;
