# 🍕 Pizza Sales SQL Analysis Project

## 🧾 Overview
This project analyzes a **Pizza Sales dataset** using **SQL** to uncover valuable business insights such as revenue trends, customer preferences, and product performance.  
It demonstrates essential SQL concepts used in real-world analytics — including joins, aggregations, subqueries, and window functions — all crucial skills for a **Data Analyst** role.

---

## 🎯 Objectives
- Analyze total orders and revenue  
- Identify top-selling pizzas and categories  
- Find the most popular pizza sizes  
- Examine hourly and daily sales patterns  
- Calculate revenue contribution by category  
- Track cumulative revenue growth over time  

---

## 🗃️ Database Schema

### Database Creation
```sql
-- Create pizza_sales database
CREATE DATABASE pizza_sales;
````

### Tables

```sql
-- Create orders table
CREATE TABLE orders (
  order_id INT NOT NULL,
  order_date DATE NOT NULL,
  order_time TIME NOT NULL,
  PRIMARY KEY (order_id)
);

-- Create order_details table
CREATE TABLE order_details (
  order_details_id INT NOT NULL,
  order_id INT NOT NULL,
  pizza_id TEXT NOT NULL,
  quantity INT NOT NULL,
  PRIMARY KEY (order_details_id)
);
```

Additional supporting tables:

* **pizzas** → `pizza_id`, `pizza_type_id`, `size`, `price`
* **pizza_types** → `pizza_type_id`, `name`, `category`

---

## 💼 Business Problems and Solutions

#### 1️⃣ Retrieve the total number of orders placed

```sql
SELECT COUNT(order_id)
FROM orders;
```

#### 2️⃣ Calculate the total revenue generated from pizza sales

```sql
SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id;
```

#### 3️⃣ Identify the highest-priced pizza

```sql
SELECT pizza_types.name, price
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;
```

#### 4️⃣ Identify the most common pizza size ordered

```sql
SELECT pizzas.size, COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;
```

#### 5️⃣ List the top 5 most ordered pizza types along with their quantities

```sql
SELECT pizza_types.name, SUM(order_details.quantity) AS total_quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;
```

---

#### 6️⃣ Find total quantity of each pizza category ordered

```sql
SELECT pizza_types.category, COUNT(order_details.quantity) AS total_quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;
```

#### 7️⃣ Determine distribution of orders by hour of the day

```sql
SELECT HOUR(order_time), COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);
```

#### 8️⃣ Category-wise distribution of pizzas

```sql
SELECT category, COUNT(name) AS count_of_pizza
FROM pizza_types
GROUP BY category;
```

#### 9️⃣ Average number of pizzas ordered per day

```sql
SELECT ROUND(AVG(quantity), 0) AS order_per_day
FROM (
  SELECT orders.order_date, SUM(order_details.quantity) AS quantity
  FROM orders
  JOIN order_details ON orders.order_id = order_details.order_id
  GROUP BY orders.order_date
) AS order_quantity;
```

#### 🔟 Top 3 most ordered pizza types based on revenue

```sql
SELECT pizza_types.name, SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
```

---

#### 1️⃣1️⃣ Percentage contribution of each pizza category to total revenue

```sql
SELECT pizza_types.category, 
ROUND(
  (SUM(order_details.quantity * pizzas.price) /
   (SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2)
    FROM order_details
    JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100, 2
) AS revenue
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC
LIMIT 3;
```

#### 1️⃣2️⃣ Analyze cumulative revenue over time

```sql
SELECT order_date,
SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM (
  SELECT orders.order_date,
         SUM(order_details.quantity * pizzas.price) AS revenue
  FROM pizzas
  JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
  JOIN orders ON order_details.order_id = orders.order_id
  GROUP BY orders.order_date
) AS sales;
```

#### 1️⃣3️⃣ Top 3 most ordered pizza types by category (based on revenue)

```sql
SELECT name, revenue
FROM (
  SELECT category, name, revenue,
         RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
  FROM (
    SELECT pizza_types.category, pizza_types.name,
           SUM(order_details.quantity * pizzas.price) AS revenue
    FROM pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
  ) a
) b
WHERE rn <= 3;
```

---

## 📊 Insights

* The **top 5 pizza types** generate the majority of total sales.
* **Medium size pizzas** are the most commonly ordered.
* Most orders occur between **6 PM and 9 PM** (dinner rush).
* **Classic and Supreme** categories contribute the most to revenue.
* Cumulative revenue shows consistent growth over time.

---

✅ *Feel free to fork, modify, or reference this project for learning and portfolio purposes.*

```
