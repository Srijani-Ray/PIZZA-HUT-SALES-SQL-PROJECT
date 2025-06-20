CREATE DATABASE PIZZAHUT;





CREATE table orders
 (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) 
); 
select * from orders;


CREATE table order_details 
(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
); 
select * from order_details; 



-- BASIC QUESTIONS :

-- Retrieve the total number of orders placed.
select count(order_id) as total_orders 
from orders; 

-- Calculate the total revenue generated from pizza sales.
select round( sum(quantity * price) ,2) as total_sales
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id;

-- Identify the highest-priced pizza.
select name,price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc
limit 1;

-- Identify the most common pizza size ordered.
select size , count(order_details_id)as order_count
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id 
group by size
order by order_count desc
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select name , sum(quantity) as order_count
from pizza_types 
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by name
order by  order_count desc
limit 5;


-- INTERMEDIATE QUESTIONS:


-- Join the necessary tables to find the total quantity of each pizza category ordered.
select category , sum(quantity) as total_quantity
from pizza_types 
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by category
order by total_quantity desc;

-- Determine the distribution of orders by hour of the day.
select hour(order_time) hour , count(order_id) order_count
from orders
group by hour ;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category , count(name) 
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(total_quantity),0) as avg_pizza_ordered_per_day
from
(select order_date , sum(quantity) as total_quantity
from  orders join order_details 
on orders.order_id = order_details.order_id
group by order_date) as order_quantity_table;

-- Determine the top 3 most ordered pizza types based on revenue.
select name , sum(price*quantity) as revenue
from pizzas 
join pizza_types on  pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by name
order by revenue desc
limit 3;


-- ADVANCED: 


-- Calculate the percentage contribution of each pizza type to total revenue.

select category,round(sum(price*quantity/(select sum(quantity*price) as total_sales 
      from order_details join pizzas on pizzas.pizza_id=order_details.pizza_id))*100,2) as percent_revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by category
order by percent_revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over (order by order_date) as cum_revenue
from
(select order_date , sum(quantity*price) as revenue
from orders
join order_details on order_details.order_id=orders.order_id
join pizzas on pizzas.pizza_id=order_details.pizza_id
group by order_date) as rev_table;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name,total_revenue
from
(select category,name, total_revenue,rank () over(partition by category order by total_revenue desc) as rn 
from 
(select category, name,sum(quantity*price) as total_revenue
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by category, name) as a) as b
where rn<=3;



 
 