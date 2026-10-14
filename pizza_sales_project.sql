# PIZZA SALES SQL PROJECT 


CREATE DATABASE PizzaHut;
USE PizzaHut;
CREATE TABLE pizza_types(
pizza_type_id INT PRIMARY KEY,
name VARCHAR(50),
category VARCHAR(20),
ingredients VARCHAR(100) 
);
SELECT COUNT(*) FROM pizza_types_mysql_ready;

CREATE TABLE orders(
order_id INT PRIMARY KEY,
order_date DATE NOT NULL,
order_time TIME NOT NULl);

SELECT COUNT(*) FROM orders;



# 1. Retrieve the total number of orders placed.
SELECT COUNT(*) AS Total_orders FROM orders;

# 2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(o.quantity * p.price), 2)
FROM
    pizzas p
        INNER JOIN
    order_details o ON p.pizza_id = o.pizza_id;
    
# 3. Identify the highest-priced pizza.
SELECT 
    p.name, pp.price
FROM
    pizza_types_mysql_ready p
        JOIN
    pizzas pp ON p.pizza_type_id = pp.pizza_type_id
ORDER BY pp.price DESC
LIMIT 1;

# 4. Identify the most common pizza size ordered.

SELECT 
    p.size AS Pizza_size,
    COUNT(o.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

# 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    p.name, SUM(o.quantity) AS total_quantity
FROM
    pizza_types_mysql_ready p
        JOIN
    pizzas pp ON p.pizza_type_id = pp.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = pp.pizza_id
GROUP BY p.name
ORDER BY total_quantity DESC
LIMIT 5;

# 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    p.category, SUM(o.quantity) AS Quantity
FROM
    pizza_types_mysql_ready p
        JOIN
    pizzas pp ON p.pizza_type_id = pp.pizza_type_id
        JOIN
    order_details o ON pp.pizza_id = o.pizza_id
GROUP BY category
ORDER BY Quantity DESC; 

# 7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY Hour;

# 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category AS Category, COUNT(name) AS Pizza
FROM
    pizza_types_mysql_ready
GROUP BY Category;

# 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(orders_per_day), 0)
FROM
    (SELECT 
        o.order_date, SUM(oo.quantity) AS orders_per_day
    FROM
        orders o
    JOIN order_details oo ON o.order_id = oo.order_id
    GROUP BY o.order_date) AS avg_pizzas_ordered;
    
# 10. Determine the top 3 most ordered pizza types based on revenue

SELECT 
    p.name, SUM(o.quantity * pp.price) AS revenue
FROM
    pizzas pp
        JOIN
    pizza_types_mysql_ready p ON p.pizza_type_id = pp.pizza_type_id
        JOIN
    order_details o ON pp.pizza_id = o.pizza_id
GROUP BY p.name
ORDER BY revenue DESC
LIMIT 3;
# 11 .  Calculate the percentage contribution of each pizza category type to total revenue.

SELECT 
    p.category, ROUND(SUM(o.quantity * pp.price) /( SELECT 
    ROUND(SUM(o.quantity * pp.price), 2) AS total_sales
FROM
    order_details o
        JOIN pizzas pp
        ON pp.pizza_id=o.pizza_id ) *100,2) AS revenue 
    FROM pizza_types_mysql_ready p JOIN pizzas pp
    ON p.pizza_type_id = pp.pizza_type_id
        JOIN
    order_details o
    ON pp.pizza_id = o.pizza_id
    GROUP BY p.category
    ORDER BY revenue DESC;
# 12. Analyze the cumulative revenue generated over time.

SELECT order_date , SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue 
FROM (SELECT oo.order_date AS order_date, SUM(o.quantity * pp.price) AS revenue
FROM orders oo
JOIN order_details o
ON oo.order_id = o.order_id 
JOIN 
pizzas pp
ON pp.pizza_id=o.pizza_id
GROUP BY order_date ) AS running_total;

# 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name , revenue FROM 
(SELECT category , name, revenue , 
RANK() OVER(PARTITION BY category ORDER BY revenue desc) as rn 
FROM 
( SELECT p.category , p.name ,
SUM((o.quantity) * pp.price) AS revenue 
FROM pizza_types_mysql_ready p JOIN pizzas pp
ON p.pizza_type_id = pp.pizza_type_id
JOIN order_details o
ON o.pizza_id=pp.pizza_id
GROUP BY p.category , p.name) AS a ) AS b
WHERE rn <=3;

