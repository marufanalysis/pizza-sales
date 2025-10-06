-- Create pizza_sales database
CREATE DATABASE pizza_sales;

-- Create orders table
CREATE TABLE orders (
	order_id	INT NOT NULL,
	order_date	DATE NOT NULL,
	order_time	TIME NOT NULL,
PRIMARY KEY (order_id)
);

-- Create order_details table
CREATE TABLE order_details (
	order_details_id	INT NOT NULL,
	order_id			INT NOT NULL,
	pizza_id			TEXT NOT NULL,
	quantity			INT NOT NULL,
PRIMARY KEY (order_details_id)
);

-- Basic:
-- Retrieve the total number of orders placed.
SELECT COUNT(order_id)
FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM order_details
JOIN pizzas 
ON  order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
SELECT pizza_types.name, price
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT pizzas.size, COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name, SUM(order_details.quantity) AS total_quantity
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC LIMIT 5;

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, COUNT(order_details.quantity) AS total_quantity
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time), COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name) AS count_of_pizza
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity), 0) AS order_per_day
FROM
(SELECT orders.order_date, SUM(order_details.quantity) as quantity
FROM orders
JOIN order_details
on orders.order_id = order_details.order_id
GROUP BY orders.order_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name, SUM(order_details.quantity * pizzas.price) as revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name 
ORDER BY revenue DESC LIMIT 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category, 
ROUND((SUM(order_details.quantity * pizzas.price) / 
(SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM order_details
JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id)) *100,2 )  as revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category 
ORDER BY revenue DESC LIMIT 3;

-- Analyze the cumulative revenue generated over time.
SELECT order_date,
SUM(revenue) OVER(ORDER BY order_date) as cum_revenue
FROM
(SELECT orders.order_date,
SUM(order_details.quantity * pizzas.price) as revenue
FROM pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
JOIN orders
ON order_details.order_id = orders.order_id
GROUP BY orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, revenue
FROM
(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) as rn
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category, pizza_types.name) a) b
WHERE rn <= 3;
