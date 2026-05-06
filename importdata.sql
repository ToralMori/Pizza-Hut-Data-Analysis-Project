
--git try
-- CREATE DATABASE pizza;

-- pizzas table

CREATE TABLE pizzas(
	pizza_id VARCHAR(50) PRIMARY KEY,
	pizza_type_id VARCHAR(100) NOT NULL,
	size VARCHAR(50) NOT NULL,
	price NUMERIC(10,2) NOT NULL
);

SELECT * FROM pizzas;




-- pizza_types

CREATE TABLE pizza_types(
	pizza_type_id VARCHAR(100) PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	category VARCHAR(100) NOT NULL,
	ingredients VARCHAR(200) NOT NULL
);


copy
pizza_types (pizza_type_id, name, category, ingredients)
from'‪‪C:\Users\morit\Downloads\pizza_sales\pizza_sales\pizza_types.csv'
delimiter','
csv header;


SELECT * FROM pizza_types;



-- orders

CREATE TABLE orders(
	order_id VARCHAR(50) PRIMARY KEY,
	order_date DATE NOT NULL,
	 order_time TIME NOT NULL
);

SELECT * FROM orders;



-- order_details

CREATE TABLE order_details(
    order_details_id INT PRIMARY KEY,
	order_id INT NOT NULL,
	pizza_id VARCHAR(50) NOT NULL,
	quantity INT NOT NULL
);

SELECT * FROM order_details;




-- 1 retrieve the total number of orders placed

SELECT
	COUNT(ORDER_ID) AS TOTAL_ORDERS
FROM
	ORDERS;


-- 2 calculate the total revenue generated from pizza sales

SELECT
	ROUND(SUM(ORDER_DETAILS.QUANTITY * PIZZAS.PRICE), 2) AS TOTAL_SALES
FROM
	ORDER_DETAILS
	JOIN PIZZAS ON PIZZAS.PIZZA_ID = ORDER_DETAILS.PIZZA_ID;



-- 3 identify the highest priced pizza

select pizza_types.name,pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;


-- 4 identify the most comman pizza size ordered

select pizzas.size,count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count desc;


-- 5 list the top 5 most oedered pizza types along with their quantities

select pizza_types.name,sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by quantity limit 5;



-- 6 join the neccessary tables to find the total quantity of each pizza category oederd

select pizza_types.category,sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by quantity desc;



-- 7 determine the distribution of orders by hour of the day

select extract(hour from order_time) as hour,count(order_id) as order_count
from orders
group by extract(hour from order_time) order by order_count desc;



-- 8 join relevant tables to find the category wise distribution of pizzas

select category,count(name) 
from pizza_types group by category;



-- 9 group the orders by date and calculate the average numaber of pizzas ordered per day

select round(avg(quantity),0) as avg_pizza_order_perday
from order_quantity

with order_quantity as(
select orders.order_date,sum(order_details.quantity) as quantity
from
orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date
);



-- 10 determine the top 3 most ordered pizza types based on revenue 

select pizza_types.name,sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;



-- 11 calculate the percentage contribution of each pizza type to total revanue 

select pizza_types.category,round(sum(order_details.quantity*pizza.price)/
(select round(sum(order_details.quantity*pizza.price),2) as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id)
*100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc;



-- 12 analyze the cumalative revanue generated over time 

select order_date,sum(revenue) over (order by order_details) as cum_revenue 
from 
(select orders.order_date,sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;


-- 13 determine the top 3 most ordered pizza types based on revanue for each pizza category 

select name,revenue 
from 
(select category,name,revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name,sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id 
group by pizza_types.category,pizza_types.name)
as a) as b
where rn <=3;

 


 