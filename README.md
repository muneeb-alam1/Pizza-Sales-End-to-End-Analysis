# 🍕 Pizza Sales Analysis SQL + Power BI

This project covers the complete data analyst workflow — from raw data exploration in MySQL 
to an interactive business dashboard in Power BI. It analyzes a full year of pizza store sales 
data to uncover revenue trends, product performance, and customer ordering behavior.

**Tools used:** MySQL · MySQL Workbench · Power BI  
**Skills demonstrated:** Joins · Aggregations · CTEs · Window Functions · 
Subqueries · Date/Time Functions · DAX · Data Modeling · Data Visualization

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql)
![Tool](https://img.shields.io/badge/Tool-MySQL%20Workbench-orange)
![PowerBI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

---

## 🎯 Project Objectives

A pizza store owner needs to understand which products drive revenue, when customers order, and 
where sales are underperforming — so they can make smarter staffing, pricing, and marketing decisions.

This project answers those questions using structured SQL analysis across four related tables 
covering a full year of order data, then visualizes the findings in an interactive Power BI 
dashboard. Specifically, the analysis aims to:

- Calculate core KPIs: total revenue, order volume, average order value, and pizzas sold
- Identify top and bottom performing pizzas by revenue and order volume
- Measure category and size contribution to overall sales
- Uncover hourly, daily, and monthly demand patterns
- Provide data-backed operational and marketing recommendations

---

## 🗄️ Database Schema

The dataset consists of **4 related tables**:

<img width="597" height="493" alt="image" src="https://github.com/user-attachments/assets/3d611cea-f9b5-43ac-afb3-18bd2e87eeaa" />



---

### SQL Techniques Used

**Joins & Aggregations** — combining all four tables to compute revenue,
order counts, and quantities at multiple granularities (pizza, category,
size, day, month)

**CTEs + Window Functions** — used to rank pizzas by revenue and calculate
cumulative revenue contribution across the menu

**Date/Time Functions** — extracting `DAYNAME`, `MONTHNAME`, and `HOUR`
from order timestamps to identify demand patterns by time of day, weekday,
and month

---

## 🛠️ What I Built

**SQL Layer**
- Comprehensive SQL queries using **Joins**, **Aggregations**, **CTE**, **Window Functions**, and **Subqueries**
- Executive summary with core business KPIs
- Product performance analysis (top/bottom pizzas, category wise contribution)
- Time and customer behavior analysis (peak hours, days, months, MoM trends)
- Month-over-month revenue comparison using LAG()


**Power BI Layer**
- Interactive multi-page dashboard connected to the analyzed data
- DAX measures for revenue, profit margin, MoM change, and Cumulative revenue etc
- **Current vs Previous Month Trending** line chart showing side by side comparison
  of selected metric across all 12 months in a single dynamic visual
- **Collapsible side filter panel** triggered by a button, keeps the dashboard clean when filters aren't in use.
- Custom DAX measures stored in a **dedicated Measures Table** for clean model organisation.
- Custom navigation buttons for seamless page switching
- Conditional formatting on MoM table to highlight growth and decline months

---

## 🔍 Query Preview

A few highlights from the SQL queries written in this project.

### 1. Revenue by Category

```sql
SELECT pizza_types.category, 
ROUND(SUM(pizzas.price * order_details.quantity), 2) AS Total_Revenue 
FROM pizzas 
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id 
JOIN pizza_types 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Total_Revenue DESC;
```

**Output**

<img width="291" height="125" alt="image" src="https://github.com/user-attachments/assets/deaf79fb-d215-40ed-8ec8-4c698a1c9565" />


---

### 2. What percentage of total revenue does each pizza contribute?

```sql
WITH rev AS (SELECT pizza_types.name, ROUND(SUM(pizzas.price * order_details.quantity),2) 
AS Total_Revenue FROM pizzas 
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id 
JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name)
SELECT name, ROUND(Total_Revenue * 100 / SUM(Total_Revenue) OVER(), 2) AS 
Percentage_Contribution FROM  rev
ORDER BY Percentage_Contribution DESC;
```

**Output**

<img width="344" height="352" alt="image" src="https://github.com/user-attachments/assets/00ce2f52-7a66-42ec-8248-4d6dc7f32d17" />


---

### 3. How does revenue change Month-over-Month?

```sql
WITH cte AS (SELECT YEAR(order_date) AS Yearr, MONTH(order_date) AS Month_Number,
ROUND(SUM(pizzas.price * order_details.quantity),2) AS Total_Revenue FROM pizzas 
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id 
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY Yearr, Month_Number)

SELECT Yearr, Month_Number, Total_Revenue,
LAG(Total_Revenue) OVER(ORDER BY yearr, Month_Number) AS Previous_Month_Revenue, 
ROUND(Total_Revenue - LAG(Total_Revenue) OVER(ORDER BY yearr, Month_Number), 2) AS MoM_Change,
ROUND(((Total_Revenue - LAG(Total_Revenue) OVER(ORDER BY Yearr, Month_Number)) 
/ LAG(Total_Revenue) OVER(ORDER BY Yearr, Month_Number)) * 100, 2) AS MoM_Percent_Change FROM cte;
```

**Output**

<img width="599" height="261" alt="image" src="https://github.com/user-attachments/assets/2321a923-0aa9-430c-9a44-a8936decd3fa" />


---

## 🧮 DAX Measures Preview

A few highlights from the DAX measures written in this project.

### 1. Previous Month Orders

```dax
Previous Month Orders = CALCULATE([Total Orders 2],
DATEADD('Date'[Date], -1,MONTH))
```

### 2. 3-Months Rolling Revenue

```dax
3 Months Rolling Revenue = CALCULATE([Total Revenue], 
DATESINPERIOD('Date'[Date], MAX('Date'[Date]),-3,MONTH))
```

### 3. Revenue MoM%

```dax
Revenue MoM % = DIVIDE([Latest Month Revenue] - [Previous Month Revenue],
[Previous Month Revenue])
```

---

## ⚠️ Challenges & Solutions

**Challenge 1:**
Comparing each month's revenue to the previous month required referencing a 
value from a different row — something `GROUP BY` alone cannot do

**Solution:** Used the `LAG()` window function with `ORDER BY Month_Number` to 
pull the previous month's revenue directly into the current row, then calculated 
both absolute and percentage change in the same `SELECT`.

**Challenge 2:**
Each pizza's percentage share of total revenue required the grand total to be 
visible in every row simultaneously — a standard `GROUP BY` collapses the data 
and makes this impossible

**Solution:** Used `SUM() OVER()` with no `PARTITION BY` to calculate the grand 
total across all rows without collapsing them, then divided each pizza's revenue 
by that value to get the percentage share inline.

**Challenge 3:**
The `order_date` column in the orders table was a plain date column which caused 
errors across multiple visuals Monthly Revenue showed incorrect months, MoM % calculations 
returned blanks, and time intelligence DAX functions like `DATEADD()`failed entirely because 
Power BI requires a properly marked Date Table to function correctly

**Solution:** Built a dedicated Date Table using `CALENDAR()` in DAX covering the full year
of the dataset:


```dax
Date = 
CALENDAR(
    DATE(2015, 1, 1),
    DATE(2015, 12, 31)
)
```

Then added supporting columns (Day Name, Month Name, Month Number etc.), marked it as the 
official Date Table, and linked it to `orders[order_date]` resolving all visual errors and 
enabling correct MoM calculations and time intelligence functions throughout the dashboard.

**Challenge 4:**
The Current vs Previous Month Trending chart needed to switch between Total Orders, Total Revenue,
and QTY Sold — building separate charts for each metric would clutter the dashboard

**Solution:** Built a dynamic **Metric Selection slicer** using Power BI **Field Parameters** to 
toggle between all three metrics in real time within a single visual:

```dax
Metric Selection = {
    ("Total Orders", NAMEOF('Measure Table'[Total Orders]), 0),
    ("Total Revenue", NAMEOF('Measure Table'[Total Revenue]), 1),
    ("QTY Sold", NAMEOF('Measure Table'[Total QTY Sold]), 2)
}
```

---

## 📊 Power BI Dashboard

The SQL findings were then visualized in an interactive Power BI dashboard.The dashboard translates
the query results into clear business visuals that a non-technical stakeholder can explore and act on.



### Dashboard Pages

A **4-page interactive Power BI dashboard**, each page designed to 
answer one core business question:

**Overall Summary** — What are the overall sales numbers and top performers?
**Order Analysis** — When and how are customers ordering?
**Pizza Performance** — Which pizzas and categories drive the most revenue?
**Time Intelligence** — How does revenue trend and change month over month?


### Dashboard Preview

#### Page 1 — Summary
<img width="947" height="550" alt="image" src="https://github.com/user-attachments/assets/f15c6dc9-0ed4-421d-bfd4-fd476660017d" />



#### Page 2 — Order Analysis
<img width="947" height="548" alt="image" src="https://github.com/user-attachments/assets/d574462b-b2fa-4ba7-8d69-ab19e6adc4ec" />



#### Page 3 — Pizza Performance
<img width="947" height="548" alt="image" src="https://github.com/user-attachments/assets/f56ddafa-9395-40a2-9d83-1439caafda17" />



#### Time Analysis
<img width="957" height="548" alt="image" src="https://github.com/user-attachments/assets/4da92e93-af5b-4851-881a-74d37fc27644" />


---

## 📊 Key Insights

**Revenue & Volume KPIs**
- Total revenue generated: **$817,860**
- Total orders placed: **21,350**
- Total pizzas sold: **49,574**
- Average Order Value (AOV): **$38.31**

**Order Behavior**
- **Afternoon** is the busiest period with 9.8K orders matching the 
  12–1 PM lunch peak
- **Friday** records the highest daily orders across the week
- **Weekday** orders 15.6K significantly outpace weekend orders 5.8K
- Orders increase sharply on Friday afternoons particularly during lunch hours

**Product Performance**
- **Classic** category leads in total orders at 10.9K
- **Thai Chicken Pizza** generates the highest revenue at $43,434
  contributing 34% of top 3 pizza revenue combined
- **Large** size dominates at 19K units sold vs 15.6K for Medium
- The bottom 3 pizzas (Brie Carre, Green Garden, Spinach Supreme) are the weakest
  performers, with the Spinach Supreme showing the steepest decline at -37.43% revenue versus the prior period.

**Time & Revenue Trends**
- **July** is the best revenue performing month
- **October** is the worst revenue performing month
- **November** shows the strongest MoM recovery at +8.87% orders and 
  +9.95% revenue
- **September** has the steepest decline at -9.78% Orders MoM, -6.00% Revenue MoM and 
  -6.67% QTY MoM
- Rolling 3-month revenue stabilizes above $200K from March onward

---

## 💡 Business Recommendations

1. **Promote top sellers more:** Bundle Thai Chicken Pizza with a drink or side
   to increase the average order value without changing the menu.

2. **Focus marketing on Fridays:** Since Friday is the busiest day, run weekly
   specials or loyalty rewards on that day to bring in even more customers.

3. **Prepare for peak hours:** Add more kitchen staff during 12–1 PM and
   5–7 PM to reduce wait times and handle higher order volume smoothly.

4. **Boost slow months:** Run limited-time deals or promotions in October and
   other low-revenue months to keep sales stable throughout the year.

5. **Fix or remove weak pizzas:** Bottom-performing pizzas are taking up menu
   space. Either offer a limited-time discount to test demand, or replace them
   with new options.

6. **Capitalise on weekday traffic:** Since 73% of orders come from weekdays,
   introduce weekday loyalty programs to retain and grow the core customer base.

7. **Manage inventory better:** Stock more ingredients for top-selling pizzas
   (especially Classic and Thai Chicken) to avoid running out during peak times.

---

## 🚀 How to Use

### SQL Analysis
1. Clone or download this repository
2. Import the dataset from the `data/` folder into MySQL
3. Open MySQL Workbench and run the files in the `queries/` folder in order
4. Each file includes inline comments explaining the business question and insight

### Power BI Dashboard
1. Download the `.pbix` file from the `dashboard/` folder
2. Open in Power BI Desktop
3. Use slicers and filters to explore the findings interactively

---

## 📌 Future Improvements
- Customer segmentation using RFM analysis once customer ID data is available
- Predictive monthly revenue forecasting using trend extrapolation
- Publish dashboard to Power BI Service for a live shareable link
